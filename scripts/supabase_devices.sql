-- Limit urządzeń na koncie — przeciwdziała współdzieleniu loginu/hasła.
-- Nowe urządzenie może się zarejestrować tylko jeśli konto ma mniej niż 3
-- zarejestrowane; ponad limit klient dostaje błąd RLS przy insert i traktuje
-- to jako brak autoryzacji Premium na tym urządzeniu (patrz UserDevices_VM.swift,
-- AuthService_VM.refreshPremiumStatus). Idempotentne — bezpieczne do
-- wielokrotnego uruchomienia w Supabase SQL Editor.

create table if not exists user_devices (
  user_id     uuid references auth.users(id) on delete cascade,
  device_id   text not null,
  device_name text,
  last_seen   timestamptz default now(),
  created_at  timestamptz default now(),
  primary key (user_id, device_id)
);

alter table user_devices enable row level security;

drop policy if exists "Users see own devices" on user_devices;
create policy "Users see own devices" on user_devices for select using (auth.uid() = user_id);

-- Limit 3 urządzeń: insert nowego wiersza (nie update przy on conflict) przechodzi
-- tylko jeśli konto ma jeszcze mniej niż 3 zarejestrowane urządzenia.
drop policy if exists "Users insert own device up to limit" on user_devices;
create policy "Users insert own device up to limit" on user_devices
  for insert
  with check (
    auth.uid() = user_id
    and (select count(*) from user_devices d where d.user_id = auth.uid()) < 3
  );

drop policy if exists "Users update own device" on user_devices;
create policy "Users update own device" on user_devices for update using (auth.uid() = user_id);

drop policy if exists "Users delete own device" on user_devices;
create policy "Users delete own device" on user_devices for delete using (auth.uid() = user_id);
