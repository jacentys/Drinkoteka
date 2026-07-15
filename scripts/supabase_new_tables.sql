
-- ============================================================
-- NOTATKI UŻYTKOWNIKÓW
-- ============================================================

create table if not exists user_notes (
  user_id    uuid references auth.users(id) on delete cascade,
  drink_id   text references drinks(id) on delete cascade,
  note       text not null,
  updated_at timestamptz default now(),
  primary key (user_id, drink_id)
);

alter table user_notes enable row level security;
drop policy if exists "Users see own notes" on user_notes;
create policy "Users see own notes" on user_notes for select using (auth.uid() = user_id);
drop policy if exists "Users insert own notes" on user_notes;
create policy "Users insert own notes" on user_notes for insert with check (auth.uid() = user_id);
drop policy if exists "Users update own notes" on user_notes;
create policy "Users update own notes" on user_notes for update using (auth.uid() = user_id);
drop policy if exists "Users delete own notes" on user_notes;
create policy "Users delete own notes" on user_notes for delete using (auth.uid() = user_id);

-- ============================================================
-- UWAGI DO DRINKÓW (feedback dla dewelopera)
-- ============================================================

create table if not exists drink_feedback (
  id         bigint generated always as identity primary key,
  user_id    uuid references auth.users(id) on delete set null,
  drink_id   text references drinks(id) on delete cascade,
  feedback   text not null,
  created_at timestamptz default now()
);

alter table drink_feedback enable row level security;
drop policy if exists "Users can insert feedback" on drink_feedback;
create policy "Users can insert feedback" on drink_feedback for insert with check (true);
drop policy if exists "Only service role sees feedback" on drink_feedback;
create policy "Only service role sees feedback" on drink_feedback for select using (false);

-- ============================================================
-- PROFILE UŻYTKOWNIKÓW (premium itp.)
-- ============================================================

create table if not exists profiles (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  is_premium boolean default false,
  updated_at timestamptz default now()
);

alter table profiles enable row level security;
drop policy if exists "Users see own profile" on profiles;
create policy "Users see own profile" on profiles for select using (auth.uid() = user_id);
-- UWAGA: brak polityki UPDATE dla klienta — is_premium ustawia się wyłącznie
-- ręcznie (SQL Editor / service_role) albo przez verify-subscription (service_role).
-- Zapobiega samodzielnemu włączeniu premium przez użytkownika.

-- Auto-tworzenie profilu przy rejestracji
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (user_id) values (new.id)
  on conflict do nothing;
  return new;
end;
$$ language plpgsql security definer;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();


-- ============================================================
-- POZWOLENIA UŻYTKOWNIKÓW NA KATEGORIE
-- ============================================================

create table if not exists user_permissions (
  user_id    uuid references auth.users(id) on delete cascade,
  permission text not null,
  primary key (user_id, permission)
);

alter table user_permissions enable row level security;
drop policy if exists "Users see own permissions" on user_permissions;
create policy "Users see own permissions" on user_permissions for select using (auth.uid() = user_id);
-- INSERT/UPDATE/DELETE tylko przez service_role (ręcznie w Supabase przez dewelopera)


-- ============================================================
-- BLOKOWANE ŹRÓDŁA (kategorie) + RLS NA DRINKACH
-- ============================================================

-- Mapowanie: źródło drinka (drZrodlo) -> wymagane pozwolenie.
-- Źródła NIE wymienione tutaj są dostępne dla wszystkich.
create table if not exists restricted_sources (
  source     text primary key,
  permission text not null
);

alter table restricted_sources enable row level security;
-- Publiczny odczyt (aplikacja pobiera mapowanie do UI i filtrowania)
drop policy if exists "Anyone can read restricted_sources" on restricted_sources;
create policy "Anyone can read restricted_sources" on restricted_sources for select using (true);

-- Przykład: zablokuj kategorię "Przepisy na proste drinki"
insert into restricted_sources (source, permission)
values ('Przepisy na proste drinki', 'category:przepisy_na_proste_drinki')
on conflict do nothing;

-- RLS na tabeli drinks: wiersz widoczny gdy źródło nie jest blokowane,
-- albo użytkownik ma odpowiednie pozwolenie w user_permissions.
alter table drinks enable row level security;
drop policy if exists "Drinks visible by permission" on drinks;
create policy "Drinks visible by permission" on drinks for select using (
    not exists (
      select 1 from restricted_sources rs where rs.source = drinks.source
    )
    or exists (
      select 1
      from restricted_sources rs
      join user_permissions up
        on up.permission = rs.permission
       and up.user_id = auth.uid()
      where rs.source = drinks.source
    )
  );

-- RLS na tabelach zależnych: widoczne tylko gdy powiązany drink jest widoczny
-- (podzapytanie zwróci wiersz tylko dla drinków przepuszczonych przez RLS drinks).
alter table drink_ingredients enable row level security;
drop policy if exists "Drink ingredients visible with drink" on drink_ingredients;
create policy "Drink ingredients visible with drink" on drink_ingredients for select using (
    exists (select 1 from drinks d where d.id = drink_ingredients.drink_id)
  );

alter table drink_steps enable row level security;
drop policy if exists "Drink steps visible with drink" on drink_steps;
create policy "Drink steps visible with drink" on drink_steps for select using (
    exists (select 1 from drinks d where d.id = drink_steps.drink_id)
  );

alter table drink_spirits enable row level security;
drop policy if exists "Drink spirits visible with drink" on drink_spirits;
create policy "Drink spirits visible with drink" on drink_spirits for select using (
    exists (select 1 from drinks d where d.id = drink_spirits.drink_id)
  );


-- ============================================================
-- OGÓLNA OPINIA O APLIKACJI
-- ============================================================

create table if not exists app_feedback (
  id         bigint generated always as identity primary key,
  user_id    uuid references auth.users(id) on delete set null,
  feedback   text not null,
  created_at timestamptz default now()
);

alter table app_feedback enable row level security;
drop policy if exists "Anyone can insert app feedback" on app_feedback;
create policy "Anyone can insert app feedback" on app_feedback for insert with check (true);
drop policy if exists "Only service role sees app feedback" on app_feedback;
create policy "Only service role sees app feedback" on app_feedback for select using (false);


-- ============================================================
-- TŁUMACZENIA TREŚCI (drinki, składniki, przepisy)
-- ============================================================
-- Tabele bazowe (drinks, ingredients, drink_steps, drink_ingredients)
-- przechowują wersję POLSKĄ (fallback). Tabele *_translations trzymają
-- pozostałe języki. Aplikacja pobiera wybrany język; brak = fallback PL.
-- `lang` to kod ISO: 'en', 'de', 'es', ...

create table if not exists drink_translations (
  drink_id text references drinks(id) on delete cascade,
  lang     text not null,
  name     text,
  note     text,
  remarks  text,
  primary key (drink_id, lang)
);

create table if not exists drink_step_translations (
  drink_id    text references drinks(id) on delete cascade,
  step_no     int  not null,
  lang        text not null,
  description text,
  primary key (drink_id, step_no, lang)
);

create table if not exists drink_ingredient_translations (
  drink_id      text references drinks(id) on delete cascade,
  ingredient_id text references ingredients(id) on delete cascade,
  lang          text not null,
  info          text,
  primary key (drink_id, ingredient_id, lang)
);

create table if not exists ingredient_translations (
  ingredient_id text references ingredients(id) on delete cascade,
  lang          text not null,
  name          text,
  description   text,
  primary key (ingredient_id, lang)
);

-- RLS: tłumaczenia drinków widoczne tylko gdy powiązany drink jest widoczny
-- (dziedziczy blokadę kategorii). Tłumaczenia składników — publiczne.
alter table drink_translations enable row level security;
drop policy if exists "Drink translations visible with drink" on drink_translations;
create policy "Drink translations visible with drink" on drink_translations for select using (
    exists (select 1 from drinks d where d.id = drink_translations.drink_id)
  );

alter table drink_step_translations enable row level security;
drop policy if exists "Drink step translations visible with drink" on drink_step_translations;
create policy "Drink step translations visible with drink" on drink_step_translations for select using (
    exists (select 1 from drinks d where d.id = drink_step_translations.drink_id)
  );

alter table drink_ingredient_translations enable row level security;
drop policy if exists "Drink ingredient translations visible with drink" on drink_ingredient_translations;
create policy "Drink ingredient translations visible with drink" on drink_ingredient_translations for select using (
    exists (select 1 from drinks d where d.id = drink_ingredient_translations.drink_id)
  );

alter table ingredient_translations enable row level security;
drop policy if exists "Anyone can read ingredient translations" on ingredient_translations;
create policy "Anyone can read ingredient translations" on ingredient_translations for select using (true);


-- ============================================================
-- PREMIUM / UPRAWNIENIA KATEGORII — przyznawane WYŁĄCZNIE ręcznie
-- ============================================================
-- Kody aktywacyjne (redemption_codes/code_redemptions/redeem_code) zostały
-- usunięte — patrz supabase_remove_activation_codes.sql. Premium i dostęp
-- do kategorii przyznaje się teraz wyłącznie bezpośrednim UPDATE/INSERT
-- w Supabase (SQL Editor albo service_role), nigdy z poziomu klienta.

-- NAPRAWA LUKI: klient nie może sam ustawić is_premium.
-- Premium przyznaje się wyłącznie ręcznie (SQL Editor / service_role). Aplikacja tylko czyta profil.
drop policy if exists "Users update own profile" on profiles;


-- ============================================================
-- USUWANIE KONTA (wymóg Apple: usuwanie konta z poziomu aplikacji)
-- ============================================================
-- Funkcja usuwa WYŁĄCZNIE konto wywołującego (auth.uid()). Powiązane dane
-- (profiles, user_notes, user_permissions) znikają kaskadowo dzięki
-- "on delete cascade"; feedback ma "on delete set null".
-- Działa jako właściciel funkcji (SECURITY DEFINER) — klient z kluczem anon
-- nie ma bezpośredniego dostępu do auth.users.

create or replace function delete_user()
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;
  delete from auth.users where id = auth.uid();
end $$;

-- Tylko zalogowani mogą wywołać (usuwają samych siebie); odbierz anonimom.
revoke execute on function delete_user() from anon, public;
grant execute on function delete_user() to authenticated;


-- ============================================================
-- ROLA ADMINISTRATORA (edycja wszystkich przepisów)
-- ============================================================
-- Flaga admina na profilu. Nadaj RĘCZNIE swojemu kontu w SQL Editor:
--   update profiles set is_admin = true where user_id =
--     (select id from auth.users where email = 'jacek@skrobisz.com');
-- (v1: edycja przepisów jest lokalna w aplikacji; is_admin steruje tylko UI.
--  Przy przyszłym zapisie treści na serwer trzeba dodać RLS zależne od is_admin.)

alter table profiles add column if not exists is_admin boolean default false;


-- ============================================================
-- ZAPIS EDYCJI PRZEZ ADMINA (kroki przepisu)
-- ============================================================
-- Rola admina egzekwowana po stronie serwera (nie ufamy fladze z klienta).

create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select coalesce((select is_admin from profiles where user_id = auth.uid()), false);
$$;

-- Admin może dodawać/edytować/usuwać kroki przepisów (baza PL) i ich tłumaczenia.
drop policy if exists "Admins manage drink_steps" on drink_steps;
create policy "Admins manage drink_steps" on drink_steps
  for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists "Admins manage drink_step_translations" on drink_step_translations;
create policy "Admins manage drink_step_translations" on drink_step_translations
  for all using (public.is_admin()) with check (public.is_admin());


-- ============================================================
-- INDEKSY WYMAGANE DLA UPSERT ADMINA (kroki, składniki drinków)
-- ============================================================
-- UWAGA/NAPRAWA: upsert z onConflict wymaga unikalnego indeksu na tych
-- kolumnach — bez niego Postgres odrzuca zapytanie ("no unique or exclusion
-- constraint matching ON CONFLICT specification"). Brakowało indeksu dla
-- drink_steps (błąd z poprzedniej wersji tego pliku) — naprawione poniżej.

create unique index if not exists drink_steps_drink_step_idx
  on drink_steps (drink_id, step_no);

create unique index if not exists drink_ingredients_drink_sort_idx
  on drink_ingredients (drink_id, sort_order);


-- ============================================================
-- ZAPIS EDYCJI PRZEZ ADMINA (pola drinka, składniki, tłumaczenia)
-- ============================================================
-- Rozszerzenie roli admina (is_admin() zdefiniowane wyżej) na resztę
-- edytowalnych treści katalogu: podstawowe pola drinka i lista składników.
-- Moc (drProc) i kaloryczność (drKal/calories) są wyliczane w aplikacji
-- z listy składników — admin ich nie edytuje ręcznie, ale wynik przelicznika
-- jest zapisywany razem z resztą pól drinka.

drop policy if exists "Admins manage drinks" on drinks;
create policy "Admins manage drinks" on drinks
  for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists "Admins manage drink_ingredients" on drink_ingredients;
create policy "Admins manage drink_ingredients" on drink_ingredients
  for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists "Admins manage drink_translations" on drink_translations;
create policy "Admins manage drink_translations" on drink_translations
  for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists "Admins manage drink_ingredient_translations" on drink_ingredient_translations;
create policy "Admins manage drink_ingredient_translations" on drink_ingredient_translations
  for all using (public.is_admin()) with check (public.is_admin());


-- ============================================================
-- USUNIĘCIE POLA recommended (Polecane liczone losowo w aplikacji)
-- ============================================================
-- Sekcja "Polecane" na ekranie głównym losuje drinki codziennie po stronie
-- klienta (stabilny hash + data dnia) zamiast korzystać z ręcznie ustawianej
-- flagi. Kolumna nie jest już zapisywana ani odczytywana przez aplikację.

alter table drinks drop column if exists recommended;
