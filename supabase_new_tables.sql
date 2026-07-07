
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
-- UWAGA: brak polityki UPDATE dla klienta — is_premium ustawia wyłącznie
-- funkcja redeem_code (SECURITY DEFINER). Zapobiega samodzielnemu włączeniu premium.

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
-- KODY AKTYWACYJNE (premium / kategorie)
-- ============================================================
-- Realizacja WYŁĄCZNIE przez funkcję redeem_code (SECURITY DEFINER).
-- Klient nie ma bezpośredniego dostępu do tych tabel ani do zapisu
-- profiles.is_premium / user_permissions.

create table if not exists redemption_codes (
  code         text primary key,        -- np. 'PREMIUM-7K2Q'
  reward_type  text not null,           -- 'premium' | 'permission'
  reward_value text,                    -- permission: 'category:...'; premium: null
  bound_email  text,                    -- null = dowolny; lub konkretny mail
  max_uses     int  default 2,          -- kod ważny maks. 2 razy
  used_count   int  default 0,
  expires_at   timestamptz,             -- null = bez wygaśnięcia
  created_at   timestamptz default now()
);

create table if not exists code_redemptions (
  code        text references redemption_codes(code) on delete cascade,
  user_id     uuid references auth.users(id) on delete cascade,
  redeemed_at timestamptz default now(),
  primary key (code, user_id)
);

-- redemption_codes: brak policy = klient nie widzi/nie modyfikuje kodów
alter table redemption_codes enable row level security;
alter table code_redemptions enable row level security;
drop policy if exists "See own redemptions" on code_redemptions;
create policy "See own redemptions" on code_redemptions for select using (auth.uid() = user_id);

-- Funkcja realizująca kod (omija RLS, działa jako właściciel)
create or replace function redeem_code(p_code text)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  c redemption_codes;
  v_email text;
begin
  select email into v_email from auth.users where id = auth.uid();
  if v_email is null then return 'not_logged_in'; end if;

  select * into c from redemption_codes where code = p_code;
  if not found then return 'invalid'; end if;
  if c.expires_at is not null and c.expires_at < now() then return 'expired'; end if;
  if c.bound_email is not null and lower(c.bound_email) <> lower(v_email) then return 'wrong_account'; end if;
  if exists (select 1 from code_redemptions where code = p_code and user_id = auth.uid()) then
    return 'already_used';
  end if;
  if c.used_count >= c.max_uses then return 'exhausted'; end if;

  if c.reward_type = 'premium' then
    update profiles set is_premium = true where user_id = auth.uid();
  elsif c.reward_type = 'permission' then
    insert into user_permissions (user_id, permission)
      values (auth.uid(), c.reward_value) on conflict do nothing;
  else
    return 'invalid';
  end if;

  insert into code_redemptions (code, user_id) values (p_code, auth.uid());
  update redemption_codes set used_count = used_count + 1 where code = p_code;
  return 'ok';
end $$;

-- NAPRAWA LUKI: klient nie może sam ustawić is_premium.
-- Premium przyznaje wyłącznie redeem_code. Aplikacja tylko czyta profil.
drop policy if exists "Users update own profile" on profiles;


-- ============================================================
-- USUWANIE KONTA (wymóg Apple: usuwanie konta z poziomu aplikacji)
-- ============================================================
-- Funkcja usuwa WYŁĄCZNIE konto wywołującego (auth.uid()). Powiązane dane
-- (profiles, user_notes, user_permissions, code_redemptions) znikają kaskadowo
-- dzięki "on delete cascade"; feedback ma "on delete set null".
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
