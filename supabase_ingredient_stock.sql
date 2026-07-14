-- Stan posiadania składników (barek) użytkownika, synchronizowany z tabelą
-- user_ingredient_stock (per konto). Obecność wiersza = składnik "jest" w barku.
-- Analogiczny wzorzec do user_favorites. Idempotentne — bezpieczne do
-- wielokrotnego uruchomienia w Supabase SQL Editor.

create table if not exists user_ingredient_stock (
  user_id       uuid references auth.users(id) on delete cascade,
  ingredient_id text references ingredients(id) on delete cascade,
  created_at    timestamptz default now(),
  primary key (user_id, ingredient_id)
);

alter table user_ingredient_stock enable row level security;
drop policy if exists "Users see own ingredient stock" on user_ingredient_stock;
create policy "Users see own ingredient stock" on user_ingredient_stock for select using (auth.uid() = user_id);
drop policy if exists "Users insert own ingredient stock" on user_ingredient_stock;
create policy "Users insert own ingredient stock" on user_ingredient_stock for insert with check (auth.uid() = user_id);
drop policy if exists "Users delete own ingredient stock" on user_ingredient_stock;
create policy "Users delete own ingredient stock" on user_ingredient_stock for delete using (auth.uid() = user_id);
