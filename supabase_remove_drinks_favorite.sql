-- Kolumna drinks.favorite była zbędna od czasu migracji ulubionych do
-- user_favorites (per konto) — nic już jej nie zapisywało, a jedyny
-- odczyt (seed startowego drUlubiony dla nowo pobranego drinka) mógł
-- powodować, że drink z favorite=true zostawał automatycznie "dopchnięty"
-- jako ulubiony każdemu userowi przy pierwszym zalogowaniu (merge logic
-- w loadFavoritesFromSupabase). Uruchomić raz w Supabase SQL Editor.

alter table drinks drop column if exists favorite;
