# CLAUDE.md

Ten plik zawiera wskazówki dla Claude Code (claude.ai/code) przy pracy z kodem w tym repozytorium.

## Opis projektu

Drinkoteka to aplikacja iOS w SwiftUI + SwiftData do przeglądania przepisów na drinki i zarządzania zapasem składników. Backend: **Supabase** (auth, dane, uprawnienia). Model biznesowy: freemium (Premium + blokowane kategorie), wielojęzyczność (obecnie PL/EN, docelowo do ~10 języków). Nazewnictwo w kodzie jest po polsku (np. `Drinki`, `Skladniki`, `Przepis`, `Zamiennik`).

## Budowanie i uruchamianie

Projekt Xcode z jednym targetem, bez testów CLI ani lintera:

- Otwórz w Xcode: `open Drinkoteka.xcodeproj` (schemat: `Drinkoteka`)
- Budowanie z CLI: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project Drinkoteka.xcodeproj -scheme Drinkoteka -sdk iphonesimulator build`
- Brak testów jednostkowych.

## Konwencja nazewnictwa

Sufiks oznacza rolę pliku/typu:

- `_M` — modele SwiftData (`@Model`), np. `Dr_M`, `Skl_M`
- `_VM` — logika ViewModel (loadery, funkcje pomocnicze, preferencje, warstwa Supabase)
- `_V` — widoki SwiftUI

## Architektura modelu danych

Dwa główne modele SwiftData zarejestrowane w `modelContainer` w `Drinkoteka/DrinkotekaApp.swift`: `Dr_M` (drink) i `Skl_M` (składnik).

- `Model/Drink/Dr_M.swift` — drink + `DrSkladnik_M` (pozycja składnika, kaskadowe usuwanie) + `DrPrzepis_M` (krok przepisu, kaskadowe usuwanie). Pole `drZrodlo` (np. „IBA Klasyki") steruje blokadą kategorii. `czyIBA` = `drZrodlo` zaczyna się od „IBA" (darmowy dostęp bez logowania).
- `Model/Skladnik/Skl_M.swift` — składnik + `SklZamiennik_M` (zamiennik). `addZamiennik` pomija duplikaty.
- `Model/EnumModel.swift` — enumy domenowe (kategoria, słodycz, szkło, moc, `alkGlownyEnum`).

## ŹRÓDŁO DANYCH: Supabase (NIE TSV)

**Ważne:** dane pochodzą z Supabase, nie z plików TSV. Pliki `Model/TSV/*.tsv` oraz loadery `ViewModel/LadowanieCSV/**` to **martwy kod / materiał do zasilenia bazy** — nie są używane w runtime.

- Klient: `ViewModel/Supabase/SupabaseClient_VM.swift` — globalny `supabase`, **klucz anon** (publiczny/bezpieczny w kodzie). **NIGDY nie umieszczaj klucza service_role w kodzie aplikacji.**
  - Uwaga: w repo są DWA `SupabaseDTO_VM.swift` — kompilowany jest `ViewModel/Supabase/SupabaseDTO_VM.swift`; `ViewModel/SupabaseDTO_VM.swift` to nieużywany duplikat (do usunięcia).
- Loader: `ViewModel/Supabase/loadFromSupabase_VM.swift` — `loadFromSupabase(modelContext:)` pobiera drinki/składniki/przepisy z Supabase i wstawia do SwiftData. Wołany raz przy 1. uruchomieniu (flaga `setupDone` w `UserDefaults`) z `DrinkiLista_V.loadAllDrinks()`. **Loader jest idempotentny** — pomija rekordy już obecne lokalnie, więc ponowne wywołanie tylko dodaje nowe drinki i nie kasuje stanu barku (`sklStan`) ani ulubionych.
- DTO: `ViewModel/Supabase/SupabaseDTO_VM.swift` (mapowanie snake_case → pola).
- Konwersje string→enum: `ViewModel/Funkcje_VM.swift`.

## Wielojęzyczność (i18n treści)

UI tłumaczone przez String Catalog `Localizable.xcstrings` (źródłowy język: `pl`, tłumaczenia w `en`). **Treść** (nazwy, opisy, przepisy) tłumaczona w bazie:

- Tabele bazowe (`drinks`, `ingredients`, `drink_steps`, `drink_ingredients`) trzymają **wersję polską** (fallback).
- Tabele `*_translations` (`drink_translations`, `drink_step_translations`, `drink_ingredient_translations`, `ingredient_translations`) trzymają pozostałe języki, kluczowane po ID + `lang`.
- Loader pobiera tłumaczenia dla bieżącego języka (`aktualnyJezykDanych()` czyta `jezykAplikacji` z `UserDefaults`) i nakłada je na treść; brak tłumaczenia → fallback PL.
- Zmiana języka: `CustomTab_V` ma `.task(id: jezykAplikacji)` → `zsynchronizujJezyk()` → `zmienJezykDanych(modelContext:)`, które przeładowuje treść w nowym języku, **zachowując `sklStan` i ulubione**. Śledzone przez `dataLang` w `UserDefaults`. (Logika jest w `CustomTab_V`, a nie w `DrinkiLista_V`, bo po zmianie języka aplikacja wraca na zakładkę Home.)

## Uprawnienia, Premium, kody aktywacyjne

Centralny serwis: `ViewModel/Supabase/AuthService_VM.swift` (`@MainActor`, singleton `AuthService_VM.shared`). Dostęp do jego właściwości z kontekstu async wymaga `await`.

- **Premium**: `@Published isPremium` z tabeli `profiles` (`refreshPremiumStatus`). Notatki drinków są Premium-only.
- **Blokowane kategorie**: sterowane bazą przez tabelę `restricted_sources (source → permission)`. `restrictedSources` + `permissions` (z `user_permissions`) ładowane w `refreshSession`/`signIn`. `canAccessDrink(_)` / `maDostepDoZrodla(_)` decydują o widoczności. Drinki z niedostępnych źródeł są ukrywane w `DrinkiLista_V`/`Home_V`, a przez RLS **nie są nawet pobierane** z serwera. Ekran „Szczegóły konta" (`AuthProfil_V`) pokazuje `zablokowaneZrodla` z oznaczeniem dostępu.
- **Kody aktywacyjne**: pole w Preferencjach → `AuthService_VM.redeemCode(_)` → RPC `redeem_code` (SECURITY DEFINER) na serwerze. Klient NIGDY nie przyznaje sobie uprawnień bezpośrednio (RLS to blokuje). Po `ok` odświeżane są premium+uprawnienia i dociągane odblokowane drinki.
- **Synchronizacja drinków**: `ViewModel/Supabase/SyncDrinki_VM.swift` — `sprawdzAktualizacjeDrinkow` po cichu usuwa drinki bez dostępu i zwraca liczbę nowych; `DrinkiLista_V` pokazuje alert „Nowe drinki" (pobranie = idempotentny `loadFromSupabase`).
- **Feedback**: `sendDrinkFeedback` (per drink) i `sendAppFeedback` (ogólny, z Preferencji) → tabele `drink_feedback` / `app_feedback` (insert-only, odczyt tylko service_role).

## Baza danych (SQL)

Cały DDL nowych funkcji: **`supabase_new_tables.sql`** (idempotentny — każda polityka poprzedzona `drop policy if exists`, tabele `if not exists`, funkcje `create or replace`). Uruchamiać w Supabase → SQL Editor.

Zawiera: `user_notes`, `drink_feedback`, `app_feedback`, `profiles` (+ trigger auto-tworzenia), `user_permissions`, `restricted_sources` + RLS na `drinks` i tabelach zależnych, tabele `*_translations` + RLS, `redemption_codes` + `code_redemptions` + funkcja `redeem_code`.

**Bezpieczeństwo RLS:** premium/uprawnienia przyznaje wyłącznie `redeem_code` (SECURITY DEFINER). `profiles` NIE ma polityki UPDATE dla klienta (inaczej użytkownik sam włączyłby sobie premium). Tabele treści blokowanych kategorii są ukrywane przez RLS zależne od `user_permissions`. `ingredients`/`ingredient_substitutes` muszą mieć publiczny odczyt (nie są blokowane).

Pliki tłumaczeń (generowane, idempotentne `on conflict do update`): `supabase_translations_ingredients_en.sql`, `_drinks_en.sql`, `_notes_en.sql`, `_steps_en.sql`. Poprawki literówek w bazowej treści PL: `supabase_fix_typos_pl.sql`.

## Skrypty (Python)

`scripts/generate_codes.py` — generator/menedżer kodów aktywacyjnych:

- `--type premium|permission [--value category:...] [--email ...] [--uses N] [--expires-days N] [--prefix ...] --insert` — tworzy kody (domyślnie max 2 użycia); z `--insert` zapisuje wprost do bazy przez REST API, bez `--insert` drukuje SQL.
- `--list` / `--list-categories` / `--revoke KOD...` — podgląd i usuwanie.
- Klucz **service_role** czytany ze zmiennej `SUPABASE_SERVICE_KEY` lub z `scripts/.supabase_service_key` (w `.gitignore`, NIGDY w repo). SSL wymaga `certifi` (`pip3 install --user certifi`).

## Pipeline tłumaczeń treści (przy dodawaniu języka)

1. Ekstrakcja z TSV → dedup unikalnych fraz (kroki: ~982 → ~445 unikalnych).
2. Tłumaczenie unikalnych fraz (LLM, terminologia barmańska + nazwy IBA jako słownik).
3. Generacja `*_translations` SQL (`on conflict do update`), wgranie w SQL Editor.
   Fallback treści: wybrany język → PL (bazowy). Nazwy międzynarodowych koktajli zostają (wiersz tłumaczenia tylko gdy różni się od PL).

## Preferencje/ustawienia

Ustawienia i filtry to `@AppStorage` (obecne w `PrefClass_VM.swift` oraz bezpośrednio w widokach). Filtry działające w całej aplikacji (kategorie alkoholu, słodycz, moc, ulubione/dostępne, sortowanie, `jezykAplikacji`, `blokujEkran`, `setupDone`, `dataLang`) mają być spójne między widokami.

## Struktura widoków

- `Drinki View/` — lista, szczegóły, przepis, filtry (`DrinkFiltry_V`), notatka (`DrinkNotatka_V`, Premium-only), uwaga (`DrinkUwaga_V`).
- `Skladniki View/` — lista, szczegóły, zamienniki.
- `Wspolne View/` — `CustomTab_V` (zakładki + sync języka), `Rejestracja/` (logowanie, `AuthProfil_V`), `AppFeedback_V`, `Preferencje_V` (język, konto, kod aktywacyjny, opinia, reset).
- `Home/` — ekran startowy (kafelki alkoholi przełączają zakładkę na Drinki z filtrem, przez `@Binding activeTab`).

## Assety

`Assets.xcassets`: `szklo`, `alkGlowny`, `male`, `skladnikiImage`, `kolory`. `Bllenderownia/` — źródła Blender/rendery (nie część targetu).

## TODO: wdrożenie do App Store

Kluczowe braki/blokery przed wysyłką:

- **„Kup Premium" to placeholder** (`DrinkNotatka_V`) — albo IAP przez StoreKit (Guideline 3.1.1), albo na v1 ukryć i dawać Premium tylko przez darmowe kody.
- **Usuwanie konta**: `deleteAccount()` woła RPC `delete_user` — potwierdzić, że funkcja istnieje na serwerze i kasuje `auth.users` (wymóg Apple).
- **`IPHONEOS_DEPLOYMENT_TARGET = 18.4`** — prawdopodobnie za wysoko; rozważyć obniżenie.
- **Ikona**: `AppIcon.appiconset` ma tylko `ikonka.png` — potrzebne 1024×1024 bez alpha.
- **Ocena 17+** (alkohol), **Privacy Policy URL** + App Privacy labels (email, notatki, feedback).
- **Sprzątanie**: ~78× `print(...)` (owinąć w `#if DEBUG`), usunąć duplikat `SupabaseDTO_VM.swift` i martwe loadery TSV.
- Obsługa offline przy 1. uruchomieniu (recenzent na słabym wifi).
- Sign in with Apple NIE jest wymagane (tylko email/hasło).
