-- Usuwa mechanizm kodów aktywacyjnych — Premium i dostęp do kategorii
-- przyznaje się teraz WYŁĄCZNIE ręcznie (SQL Editor / service_role), nigdy
-- z poziomu klienta ani przez samoobsługowy kod. Uruchomić raz w Supabase
-- → SQL Editor. NIEODWRACALNE: kasuje historię już wykorzystanych kodów.
--
-- Przykład ręcznego przyznania po usunięciu tego mechanizmu:
--   update profiles set is_premium = true where user_id = (select id from auth.users where email = '...');
--   insert into user_permissions (user_id, permission) values ((select id from auth.users where email = '...'), 'category:...');

drop function if exists redeem_code(text);

drop policy if exists "See own redemptions" on code_redemptions;
drop table if exists code_redemptions;
drop table if exists redemption_codes;
