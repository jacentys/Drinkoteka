-- Rozszerzenie profiles o dane subskrypcji Premium (StoreKit 2 + App Store Server API).
-- Idempotentne — bezpieczne do wielokrotnego uruchomienia w Supabase SQL Editor.
-- Kolumny ustawiane WYŁĄCZNIE przez Edge Function "verify-subscription" (service_role),
-- analogicznie do is_premium ustawianego przez redeem_code — klient nigdy nie ma
-- polityki UPDATE na profiles (patrz supabase_new_tables.sql).

alter table profiles add column if not exists premium_product_id text;
alter table profiles add column if not exists premium_expires_at timestamptz;
alter table profiles add column if not exists premium_original_transaction_id text;
alter table profiles add column if not exists premium_auto_renew boolean default false;

-- Indeks do szybkiego wyszukania profilu po originalTransactionId
-- (potrzebne przy obsłudze App Store Server Notifications w przyszłości —
--  odnowienia/anulowania przychodzą z ID transakcji, nie z user_id).
create unique index if not exists profiles_premium_original_transaction_idx
  on profiles (premium_original_transaction_id)
  where premium_original_transaction_id is not null;
