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

**Ważne:** dane pochodzą z Supabase, nie z plików TSV. Pliki `Model/TSV/*.tsv` pozostają jako **materiał do zasilenia bazy i źródło do tłumaczeń** (loadery TSV zostały usunięte — nie były używane w runtime).

- Klient: `ViewModel/Supabase/SupabaseClient_VM.swift` — globalny `supabase`, **klucz anon** (publiczny/bezpieczny w kodzie). **NIGDY nie umieszczaj klucza service_role w kodzie aplikacji.**
- DTO: `ViewModel/Supabase/SupabaseDTO_VM.swift`.
- Loader: `ViewModel/Supabase/loadFromSupabase_VM.swift` — `loadFromSupabase(modelContext:)` pobiera drinki/składniki/przepisy z Supabase i wstawia do SwiftData. Wołany raz przy 1. uruchomieniu (flaga `setupDone` w `UserDefaults`) z `DrinkiLista_V.loadAllDrinks()`. **Loader jest idempotentny** — pomija rekordy już obecne lokalnie, więc ponowne wywołanie tylko dodaje nowe drinki i nie kasuje stanu barku (`sklStan`) ani ulubionych.
- DTO: `ViewModel/Supabase/SupabaseDTO_VM.swift` (mapowanie snake_case → pola).
- Konwersje string→enum: `ViewModel/Funkcje_VM.swift`.

## Wielojęzyczność (i18n treści)

UI tłumaczone przez String Catalog `Localizable.xcstrings` (źródłowy język: `pl`, tłumaczenia w `en`). **Treść** (nazwy, opisy, przepisy) tłumaczona w bazie:

- Tabele bazowe (`drinks`, `ingredients`, `drink_steps`, `drink_ingredients`) trzymają **wersję polską** (fallback).
- Tabele `*_translations` (`drink_translations`, `drink_step_translations`, `drink_ingredient_translations`, `ingredient_translations`) trzymają pozostałe języki, kluczowane po ID + `lang`.
- Loader pobiera tłumaczenia dla bieżącego języka (`aktualnyJezykDanych()` czyta `jezykAplikacji` z `UserDefaults`) i nakłada je na treść; brak tłumaczenia → fallback PL.
- Zmiana języka: `CustomTab_V` ma `.task(id: jezykAplikacji)` → `zsynchronizujJezyk()` → `zmienJezykDanych(modelContext:)`, które przeładowuje treść w nowym języku, **zachowując `sklStan` i ulubione**. Śledzone przez `dataLang` w `UserDefaults`. (Logika jest w `CustomTab_V`, a nie w `DrinkiLista_V`, bo po zmianie języka aplikacja wraca na zakładkę Home.)

## Uprawnienia, Premium

Centralny serwis: `ViewModel/Supabase/AuthService_VM.swift` (`@MainActor`, singleton `AuthService_VM.shared`). Dostęp do jego właściwości z kontekstu async wymaga `await`.

- **Premium**: `@Published isPremium` z tabeli `profiles` (`refreshPremiumStatus`). Notatki drinków są Premium-only.
- **Blokowane kategorie**: sterowane bazą przez tabelę `restricted_sources (source → permission)`. `restrictedSources` + `permissions` (z `user_permissions`) ładowane w `refreshSession`/`signIn`. `canAccessDrink(_)` / `maDostepDoZrodla(_)` decydują o widoczności. Drinki z niedostępnych źródeł są ukrywane w `DrinkiLista_V`/`Home_V`, a przez RLS **nie są nawet pobierane** z serwera. Ekran „Szczegóły konta" (`AuthProfil_V`) pokazuje `zablokowaneZrodla` z oznaczeniem dostępu.
- **Nadawanie Premium/uprawnień**: wyłącznie ręcznie, bezpośrednio w Supabase (SQL Editor albo `service_role`) — `update profiles set is_premium = true where user_id = ...` / `insert into user_permissions (...)`. Mechanizm kodów aktywacyjnych (`redeem_code`, `redemption_codes`, `code_redemptions`, `scripts/generate_codes.py`) został **usunięty** (patrz `supabase_remove_activation_codes.sql`) — klient nadal nigdy nie przyznaje sobie uprawnień sam (RLS to blokuje), po prostu nie ma już samoobsługowej ścieżki „wpisz kod".
- **Synchronizacja drinków**: `ViewModel/Supabase/SyncDrinki_VM.swift` — `sprawdzAktualizacjeDrinkow` po cichu usuwa drinki bez dostępu i zwraca liczbę nowych; `DrinkiLista_V` pokazuje alert „Nowe drinki" (pobranie = idempotentny `loadFromSupabase`). Drinki ze źródła `"Własny"` są zawsze wykluczone z tego kasowania (nigdy nie istniały na serwerze).
- **Feedback**: `sendDrinkFeedback` (per drink) i `sendAppFeedback` (ogólny, z Preferencji) → tabele `drink_feedback` / `app_feedback` (insert-only, odczyt tylko service_role).
- **Rola admina**: `profiles.is_admin` (nadawana ręcznie w SQL), `@Published isAdmin` w `AuthService_VM`. Reguły dostępu do edycji: `mozeTworzyc` (dodawanie własnych drinków — Premium lub admin), `mozeEdytowac(_:)` (admin → wszystkie drinki; Premium → tylko własne, `drZrodlo == "Własny"`), `mozeOtworzyc(_:)` (czytanie — IBA zawsze, reszta wg Premium/uprawnień kategorii).
- **Faza serwerowa B** (edycja treści katalogu przez admina, v1 częściowo zrobiona): admin edytuje kroki przepisu / pola drinka / listę składników w UI, zmiany są **wypychane na serwer** (`SyncDrinki_VM.swift`: `pushKrokiAdmin`, `pushPolaAdmin`, `pushSkladnikiAdmin`) językowo-świadomie (PL → tabele bazowe, inny język → `*_translations`). Admin może też dodać nowy drink od razu do wspólnego katalogu (`pushNowyDrinkDoKatalogu`, `drZrodlo = "Katalog"`) i usunąć dowolny drink z serwera (`usunDrinkZServera`, kaskada przez FK). Premium robi te same edycje, ale **tylko lokalnie** na własnych drinkach ("Własny") — synchronizacja treści Premium to kolejna faza, jeszcze niezrobiona. Moc (%) i kaloryczność są liczone automatycznie z listy składników (`przeliczMocIKalorie`) — nieedytowalne ręcznie. Pole `recommended`/`drPolecany` zostało całkowicie usunięte; „Polecane" na Home losowane jest codziennie po stronie klienta (stabilny hash `drinkID+data`, funkcja `stabilnyHash` w `Funkcje_VM.swift` — **nie** używać `String.hashValue`, bo jest losowany co proces).

## Baza danych (SQL)

Cały DDL nowych funkcji: **`supabase_new_tables.sql`** (idempotentny — każda polityka poprzedzona `drop policy if exists`, tabele `if not exists`, funkcje `create or replace`). Uruchamiać w Supabase → SQL Editor.

Zawiera: `user_notes`, `drink_feedback`, `app_feedback`, `profiles` (+ trigger auto-tworzenia), `user_permissions`, `restricted_sources` + RLS na `drinks` i tabelach zależnych, tabele `*_translations` + RLS. **Kody aktywacyjne usunięte** — patrz `supabase_remove_activation_codes.sql` (jednorazowa migracja, dropuje `redeem_code`/`redemption_codes`/`code_redemptions`).

**`supabase_favorites.sql`** (osobny plik, jak `supabase_subscriptions.sql`) — tabela `user_favorites (user_id, drink_id)`: obecność wiersza = drink ulubiony na koncie. Trzeba uruchomić ręcznie w SQL Editor (nie jest częścią `supabase_new_tables.sql`).

**`supabase_ingredient_stock.sql`** (analogicznie) — tabela `user_ingredient_stock (user_id, ingredient_id)`: obecność wiersza = składnik fizycznie posiadany („jest") na koncie. Synchronizowana tylko surowa wartość `jest`/nie — stany pochodne `zmJest`/`zmBrak` (dostępność przez zamiennik) przeliczają się lokalnie na każdym urządzeniu (`recalculujStanyZamiennikow`), bo zależą też od lokalnego ustawienia „zamiennikiDozwolone". Też trzeba uruchomić ręcznie w SQL Editor.

Oba mechanizmy (`UserFavorites_VM.swift`, `UserIngredientStock_VM.swift`) działają tylko gdy użytkownik jest zalogowany (bez sesji funkcje po cichu nic nie robią — ulubione/barek zostają wtedy czysto lokalne, jak wcześniej). Ładowanie po zalogowaniu **scala, nie nadpisuje**: serwer tylko dodaje stan lokalnie (nigdy nie odznacza), a lokalne dane nieznane jeszcze serwerowi (np. sprzed założenia konta) są dopychane do Supabase — więc pierwsze zalogowanie nie kasuje tego, co użytkownik już zaznaczył jako gość.

**`supabase_devices.sql`** — limit **3 urządzeń na koncie**, zabezpieczenie przed współdzieleniem loginu/hasła (opisane w rozmowie z użytkownikiem, nie jest to wymóg Apple). Tabela `user_devices (user_id, device_id, device_name, last_seen)`; RLS na `insert` liczy istniejące wiersze i odrzuca nowe urządzenie, jeśli konto ma już 3 zarejestrowane (`(select count(*) from user_devices where user_id = auth.uid()) < 3` w `with check`). `AuthService_VM.refreshPremiumStatus()` rejestruje urządzenie (`registerDeviceInSupabase()`) przy każdym odświeżeniu sesji; jeśli insert odrzucony przez RLS → `deviceAuthorized = false` → efektywne `isPremium` (`isPremiumRaw && deviceAuthorized`) jest `false` na tym urządzeniu, mimo opłaconej subskrypcji. `isAdmin` NIE jest tym objęty (nadawany ręcznie, nie ma ryzyka współdzielenia). Szczegóły konta → sekcja „Urządzenia" pozwala zobaczyć listę i usunąć stare, żeby odblokować nowe (inaczej użytkownik z 3 starymi telefonami zostałby trwale zablokowany po kupnie czwartego).

**Bezpieczeństwo RLS:** premium/uprawnienia przyznaje się wyłącznie ręcznie w Supabase (SQL Editor / `service_role`). `profiles` NIE ma polityki UPDATE dla klienta (inaczej użytkownik sam włączyłby sobie premium). Tabele treści blokowanych kategorii są ukrywane przez RLS zależne od `user_permissions`. `ingredients`/`ingredient_substitutes` muszą mieć publiczny odczyt (nie są blokowane).

Pliki tłumaczeń (generowane, idempotentne `on conflict do update`): `supabase_translations_ingredients_en.sql`, `_drinks_en.sql`, `_notes_en.sql`, `_steps_en.sql`. Poprawki literówek w bazowej treści PL: `supabase_fix_typos_pl.sql`.

## Pipeline tłumaczeń treści (przy dodawaniu języka)

1. Ekstrakcja z TSV → dedup unikalnych fraz (kroki: ~982 → ~445 unikalnych).
2. Tłumaczenie unikalnych fraz (LLM, terminologia barmańska + nazwy IBA jako słownik).
3. Generacja `*_translations` SQL (`on conflict do update`), wgranie w SQL Editor.
   Fallback treści: wybrany język → PL (bazowy). Nazwy międzynarodowych koktajli zostają (wiersz tłumaczenia tylko gdy różni się od PL).

## Preferencje/ustawienia

Ustawienia i filtry to `@AppStorage` (obecne w `PrefClass_VM.swift` oraz bezpośrednio w widokach). Filtry działające w całej aplikacji (kategorie alkoholu, słodycz, moc, ulubione/dostępne, sortowanie, `jezykAplikacji`, `blokujEkran`, `setupDone`, `dataLang`) mają być spójne między widokami.

`wygladAplikacji` (`wygladEnum`: systemowy/jasny/ciemny) steruje `.preferredColorScheme` na korzeniu aplikacji (`DrinkotekaApp.swift`). Tytuły ekranów (Home, Drinki, Składniki, Preferencje) używają wspólnego, ręcznie stylowanego `ToolbarItem(.principal)` (`.largeTitle`, `.fontWeight(.light)`, `Color.primary`, cień) zamiast systemowego `navigationTitle` — systemowy tytuł bywał niewidoczny na losowym tle `Back_V` (mesh gradient) w niektórych zestawieniach kolorów/trybów.

## Struktura widoków

- `Drinki View/` — lista, szczegóły, przepis, filtry (`DrinkFiltry_V`), notatka (`DrinkNotatka_V`, Premium-only), uwaga (`DrinkUwaga_V`).
- `Skladniki View/` — lista, szczegóły, zamienniki.
- `Wspolne View/` — `CustomTab_V` (zakładki + sync języka), `Rejestracja/` (logowanie, `AuthProfil_V` — konto, Premium, zmiana hasła, usunięcie konta), `AppFeedback_V`, `Preferencje_V` (język, konto, opinia, reset).
- `Home/` — ekran startowy (kafelki alkoholi przełączają zakładkę na Drinki z filtrem, przez `@Binding activeTab`).

## Assety

`Assets.xcassets`: `szklo`, `alkGlowny`, `male`, `skladnikiImage`, `kolory`. `Bllenderownia/` — źródła Blender/rendery (nie część targetu).

## Monetyzacja: subskrypcja Premium (StoreKit 2)

Docelowy model: apka darmowa, Premium przez **subskrypcję auto-renewable** (nie jednorazowy zakup) — dwa poziomy w jednej subscription group „Drinkotheque Premium" w App Store Connect: `film.post.Drinkoteka.premium.monthly` i `...yearly` (roczny jako „1 Year Upfront", nie „Monthly with 12-Month Commitment" — ta druga wymaga iOS 26.4+/SDK 26.5+).

- `ViewModel/Store/StoreKit_VM.swift` — ładowanie produktów, zakup, nasłuch `Transaction.updates` (odnowienia), `restorePurchases()`. Klient **nigdy** nie ustawia `isPremium` sam — po zakupie woła Edge Function i dopiero wtedy odświeża status z serwera (`AuthService_VM.refreshPremiumStatus`).
- UI zakupu: w `AuthProfil_V` („Szczegóły konta"), nie w Preferencjach — subskrypcja wymaga zalogowania, więc zgrupowana z resztą danych konta.
- Weryfikacja server-side: `supabase/functions/verify-subscription/index.ts` (Deno/Supabase Edge Function) — klient wysyła JWS transakcji, funkcja buduje JWT (ES256) i woła Apple **App Store Server API**, potem `service_role` ustawia `profiles.is_premium`/`premium_expires_at`/`premium_product_id`/`premium_original_transaction_id` (kolumny z `supabase_subscriptions.sql`).
- Klucz do JWT: **In-App Purchase Key** z App Store Connect → Users and Access → Integrations → **„In-App Purchase"** (NIE „App Store Connect API"/Team Keys — inny typ klucza, nie zadziała do tego API). Plik `.p8` żyje lokalnie w `scripts/SubscriptionKey_*.p8` (gitignored) i jako Supabase secrets: `APPLE_IAP_KEY_ID`, `APPLE_IAP_ISSUER_ID`, `APPLE_BUNDLE_ID`, `APPLE_IAP_PRIVATE_KEY` (te są wdrożone w chmurze Supabase — nie trzeba ich konfigurować per-komputer).
- Test lokalny: `Drinkoteka/StoreKitConfig.storekit` (zsynchronizowany z ASC przez „Sync this file with an app in App Store Connect"), podpięty w Edit Scheme → Run → Options → StoreKit Configuration. **Uwaga:** zakup przez ten lokalny config w Symulatorze/Xcode tworzy transakcję czysto lokalną — realne App Store Server API jej nie zna i zwraca `404 Transaction id not found` (na prod i sandbox). Do realnego testu weryfikacji server-side trzeba zainstalować build **z TestFlight** — takie buildy automatycznie transakcjonują przez środowisko Sandbox, niezależnie jakim Apple ID jest zalogowany tester na urządzeniu (osobny Sandbox Tester, zakładany w Users and Access → Sandbox → Testers, jest potrzebny tylko przy testowaniu bezpośrednio z Xcode bez TestFlight).
- `fetchTransactionInfo` w Edge Function próbuje prod, a przy **404 lub 401** przełącza się na sandbox (Apple czasem odrzuca sandboxowe transakcje na endpointcie produkcyjnym jako 401 zamiast 404).
- **Rozwiązane (był „Known issue")**: świeżo aktywowana **Paid Applications Agreement** (Business → Agreements, Tax and Banking) potrafiła nie propagować się do backendu App Store Server API przez **kilka godzin** mimo statusu „Active" w UI ASC — w tym czasie każde wywołanie zwracało **401 z pustym body**, mimo w 100% poprawnego klucza/JWT/Issuer ID/Bundle ID/Team. Samo się rozwiązało po odczekaniu (bez zmiany konfiguracji) — potwierdzone działającym zakupem end-to-end przez TestFlight.
- Darmowe przyznanie Premium (konta recenzenckie/testowe) — teraz wyłącznie ręcznym `update profiles set is_premium = true ...` w Supabase (kody aktywacyjne usunięte). Docelowo głównym kanałem darmowego rozdawania Premium mają być Apple **Offer Codes** powiązane z realnym IAP (wymóg Apple: nie można oferować "Premium" tylko za darmo bez możliwości zakupu, bez zgłoszonego IAP — stąd w ogóle to wdrożenie).

## Gałąź robocza

Praca nad i18n/premium/adminem odbywała się na gałęzi `feature/backend-i18n-premium` — **już zmergowana do `main` i skasowana** (commit `37c8a4b`). Od teraz praca dzieje się bezpośrednio na `main`.

## Status wdrożenia do App Store

**Konto Developer Program**: aktywne, opłacone. Team ID `Q379RQR2M7` (w projekcie było wcześniej błędnie `86K9YKET34` z poprzedniej konfiguracji — Xcode nadpisał na właściwy po naprawieniu podpisywania).

**App Store Connect**: rekord aplikacji utworzony — nazwa „Drinkotheque", bundle ID `film.post.Drinkoteka`, SKU `drinkotheque-001`, Apple ID `6789599579`. Company/Seller Name: **`POST sp. z o.o.`** (pole jednorazowe, nieodwracalne bez kontaktu z Apple).

**TestFlight**: build `1.0 (1)` (bez StoreKit — wysłany przed wdrożeniem subskrypcji) wysłany i przetworzony, przypisany do grupy External Testing, wysłany do **Beta App Review** (status „Waiting for Review" na dzień wysyłki). Build `1.0 (3)` (pierwszy ze StoreKit + bez wsparcia iPada) wgrany później i przetestowany end-to-end (zakup Premium przez TestFlight → `verify-subscription` → `isPremium = true`, potwierdzone działające). Grupa Internal Testing „Internal Tester" ma włączone automatic distribution — każdy nowy build trafia tam sam, bez ręcznego przypisywania. Grupa External Testing „Testy zewnętrzne" — sprawdzić, czy build 3 wymaga osobnego zatwierdzenia przez Beta App Review (nowy build może, ale nie musi, wymagać ponownego review).

**Test/reviewer konto**: `black@530.pl`, Premium przyznane (pierwotnie jednorazowym kodem aktywacyjnym — mechanizm od tamtej pory usunięty, `is_premium` w `profiles` zostaje przyznane niezależnie od tego jak). Hasło NIE jest zapisane tutaj — ustawione ręcznie przy rejestracji, do sprawdzenia u użytkownika jeśli potrzebne przy kolejnym demo review.

**Zrobione w tej rundzie**:
- „Kup Premium" — potwierdzone, że jest fizycznie usunięty z kodu (nie tylko ukryty); Premium ówcześnie tylko przez kody aktywacyjne (mechanizm ten od tamtej pory usunięty — patrz sekcja „Uprawnienia, Premium" wyżej).
- `delete_user` RPC — potwierdzone: istnieje w `supabase_new_tables.sql:315-330`, `SECURITY DEFINER`, realnie kasuje `auth.users`.
- Dodano `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` do `project.pbxproj` (Debug+Release) — eliminuje ręczne pytanie o Export Compliance przy każdym uploadzie (apka używa tylko standardowego HTTPS/TLS).
- Age Rating (17+) i App Privacy (nutrition label: Email/User ID/User Content, wszystkie Linked to Identity, App Functionality, brak trackingu) uzupełnione w App Store Connect.
- DSA „trader status" (wymóg UE, Business → Agreements w App Store Connect) potwierdzony jako trader — bez tego External Testing/dystrybucja w UE jest zablokowana.

**Pułapki napotkane przy pierwszym wdrożeniu (na przyszłość)**:
- Xcode „does not have an associated developer team" → trzeba dodać płatne konto Apple ID w Xcode → Settings → Accounts i ręcznie wybrać Team w Signing & Capabilities.
- Xcode „no devices from which to generate a provisioning profile" → wymaga podłączenia chociaż jednego fizycznego iPhone'a raz (albo ręcznego dodania UDID w developer.apple.com), nawet do zwykłego Archive/dystrybucji.
- Xcode „App Record Creation failed... missing companyName" przy Distribute App → trzeba najpierw ręcznie założyć appkę na appstoreconnect.apple.com (tam pyta o Company/Seller Name), potem wrócić do Xcode i powtórzyć Distribute App.
- Privacy Policy URL nie jest na stronie „App Information" — jest na osobnej zakładce **App Privacy**.
- External Testing (TestFlight) bywa niedostępne dopóki nie uzupełni się DSA trader compliance (Business → Agreements, czerwony baner) — dopiero po tym pojawia się sekcja External Testing w menu.
- Przy dodawaniu testera do grupy Internal/External — pole Name w Users and Access nie może zawierać nietypowych znaków (np. dwukropka), inaczej tester zostanie odrzucony jako „invalid name".
- „Unable to Add for Review — screenshot for 13-inch iPad displays" mimo wyłączenia iPada w Xcode (`TARGETED_DEVICE_FAMILY = 1`) → App Store Connect ocenia wymagane zrzuty na podstawie **już wgranej binarki**, nie bieżących ustawień projektu. Trzeba zwiększyć numer builda, zarchiwizować i wgrać **nowy build** z poprawionymi ustawieniami, a potem podmienić przypisany build w wersji na stronie ASC — dopiero to usuwa wymóg zrzutu iPada.
- **Czas oczekiwania na review**: Beta App Review (TestFlight) zwykle 24–48h (Apple deklaruje ~90% w 24h); pierwsza aplikacja na nowym koncie developerskim bywa dłużej weryfikowana. Pełny App Store review (finalne listing) trwa podobnie, czasem nieco dłużej.
- Xcode „Couldn't communicate with a helper application" przy Distribute App → zwykle zawieszony proces pomocniczy Xcode, nie problem z kontem/kluczami. Naprawia zamknięcie Xcode całkowicie (⌘Q) i ponowne otwarcie; jeśli nie pomoże — restart Maca. Obejście awaryjne: Distribute App → **Export** (zamiast Upload) → wgraj powstały `.ipa` osobną appką **Transporter** (Mac App Store), to pomija wewnętrzny helper Xcode.
- „This invitation has been revoked or is invalid" przy próbie dołączenia do TestFlight → stare zaproszenie wygasło (np. po edycji danych testera w Users and Access). Napraw usuwając testera z grupy Internal/External i dodając go ponownie — Apple wyśle nowe zaproszenie mailem.
- Nawet **Internal Testing** wymaga jednorazowej akceptacji zaproszenia mailem (link „View in TestFlight" albo kod) — samo dodanie kogoś jako testera do grupy nie sprawia, że appka pojawia się w TestFlight automatycznie bez tego kroku.
- **Beta App Review odrzucone dla builda 1** z powodem: *„We are unable to complete the review of the app because one or more of the In-App Purchase products have not been submitted for review. Specifically, the app includes references to paid content but the associated In-App Purchase products have not been submitted for review."* — subskrypcje (`film.post.Drinkoteka.premium.monthly`/`.yearly`) istnieją w App Store Connect, ale nie zostały **dołączone do submission**. Naprawa przy kolejnym submicie (build 3, który faktycznie ma kod StoreKit):
  1. App Store Connect → app → **Subscriptions** (Monetization) → sprawdzić, że każdy produkt ma komplet: nazwa, opis, cena, **Review Screenshot** (wymagany zrzut ekranu z appki pokazujący ekran zakupu subskrypcji — łatwo przeoczyć, bez niego produkt nie osiąga statusu „Ready to Submit").
  2. Przy submitowaniu builda do review (czy to pełny App Store, czy Beta App Review dla External Testing) — dołączyć te subskrypcje do submission (sekcja „In-App Purchases and Subscriptions" przy wersji/buildzie), nie tylko mieć je „wiszące" osobno w App Store Connect.

**Wciąż do zrobienia**: dołączyć subskrypcje do submission przy ponownym wysłaniu builda 3 do Beta App Review (patrz pułapka wyżej — to była przyczyna odrzucenia builda 1), potem oczekiwanie na wynik. Zrzuty ekranu — zrobione.

Zrobione wcześniej: `IPHONEOS_DEPLOYMENT_TARGET` obniżony do 17.0 (z fallbackami dla API iOS 18: `MeshGradient`, `toolbarBackgroundVisibility`), logi `print` zamienione na `dprint` (aktywne tylko w Debug — definicja w `Funkcje_VM.swift`), usunięty duplikat DTO i martwe loadery TSV, ikona (pop-art, 1024×1024), nazwa ujednolicona na „Drinkotheque" (bez akcentu — łatwiejsze wyszukiwanie), Privacy Policy + strona wsparcia wgrane na 530.pl, metadane App Store (`docs/app-store-metadata.md`), deep link potwierdzenia maila (`drinkoteka://login-callback`), animowany ekran ładowania + obsługa offline przy 1. uruchomieniu, model dostępu B (Premium wymagane dla nie-IBA, widoczne-ale-zablokowane), rola admina + faza serwerowa B (patrz wyżej), ustawienie wyglądu (systemowy/jasny/ciemny) i spójne tytuły ekranów. Sign in with Apple NIE jest wymagane (tylko email/hasło).

## Praca z kilku komputerów

Kod idzie przez git (`git pull` wystarczy), ale kilka rzeczy jest lokalnych per-maszyna i wymaga ręcznej konfiguracji przy przejściu na inny komputer:

- **`scripts/.supabase_service_key`** i **`scripts/SubscriptionKey_*.p8`** — gitignored, trzeba skopiować ręcznie (albo wygenerować nowe — `.p8` klucza In-App Purchase da się pobrać z ASC tylko RAZ przy tworzeniu, więc jeśli zgubiony, trzeba wygenerować nowy i zaktualizować sekret `APPLE_IAP_PRIVATE_KEY`).
- **Supabase CLI** — stan logowania per-maszyna: `supabase login` + `supabase link --project-ref beqxwdtkmzqonlsnbvlc`.
- **Sekrety Edge Function** (`APPLE_IAP_KEY_ID`, `APPLE_IAP_ISSUER_ID`, `APPLE_BUNDLE_ID`, `APPLE_IAP_PRIVATE_KEY`) — **NIE trzeba** ich ponownie ustawiać, są wdrożone w chmurze Supabase niezależnie od komputera.
- **Xcode signing** — przy pierwszej pracy nad projektem na nowym komputerze: dodać płatne konto Apple ID w Xcode → Settings → Accounts, wybrać Team `Q379RQR2M7` (POST sp. z o.o.) w Signing & Capabilities; może być potrzebne podłączenie fizycznego iPhone'a raz do wygenerowania provisioning profile.
