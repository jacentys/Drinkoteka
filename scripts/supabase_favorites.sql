-- Ulubione drinki użytkownika, synchronizowane z tabelą user_favorites (per konto).
-- Analogicznie do user_notes: obecność wiersza = drink jest ulubiony na tym koncie.
-- Idempotentne — bezpieczne do wielokrotnego uruchomienia w Supabase SQL Editor.

create table if not exists user_favorites (
  user_id    uuid references auth.users(id) on delete cascade,
  drink_id   text references drinks(id) on delete cascade,
  created_at timestamptz default now(),
  primary key (user_id, drink_id)
);

alter table user_favorites enable row level security;
drop policy if exists "Users see own favorites" on user_favorites;
create policy "Users see own favorites" on user_favorites for select using (auth.uid() = user_id);
drop policy if exists "Users insert own favorites" on user_favorites;
create policy "Users insert own favorites" on user_favorites for insert with check (auth.uid() = user_id);
drop policy if exists "Users delete own favorites" on user_favorites;
create policy "Users delete own favorites" on user_favorites for delete using (auth.uid() = user_id);
