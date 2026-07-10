# App Privacy Labels — ściąga do App Store Connect

Ściąga do wypełnienia sekcji **App Store Connect → App Privacy** dla aplikacji **Drinkotheque**.
Oparta na tym, co aplikacja faktycznie zbiera: email/konto, notatki, opinie (przez Supabase).
Zdjęcia własnych drinków oraz barek/ulubione/własne drinki zostają **lokalnie na urządzeniu**.

## Krok 1 — pytanie wstępne
„Do you or your third-party partners collect data from this app?" → **Yes**
(bo email i treści użytkownika trafiają do Supabase).

## Krok 2 — typy danych do zadeklarowania (3)

### 1. Contact Info → Email Address
- Collected: **Yes**
- Linked to the user's identity: **Yes**
- Used for tracking: **No**
- Purposes: **App Functionality** (rejestracja, logowanie, obsługa konta)

### 2. Identifiers → User ID
(Supabase nadaje kontu UUID zapisywane przy notatkach/opiniach)
- Collected: **Yes**
- Linked to the user's identity: **Yes**
- Used for tracking: **No**
- Purposes: **App Functionality**

### 3. User Content → Other User Content
(notatki do drinków + treść opinii/uwag)
- Collected: **Yes**
- Linked to the user's identity: **Yes**
- Used for tracking: **No**
- Purposes: **App Functionality** (notatki) oraz **Customer Support** (opinie) — zaznacz oba

## Krok 3 — czego NIE deklarujesz (świadomie)
- **Photos / zdjęcia** — zostają lokalnie na urządzeniu, nie są wysyłane → wg definicji Apple nie są „collected".
- **Barek, ulubione, własne drinki** — dane lokalne na urządzeniu → nie deklarujesz.
- **Diagnostics / Crash / Usage Data** — brak analityki i zewnętrznych SDK → nie.
- **Purchases** — brak IAP (Premium przez darmowe kody) → nie.
- **Location, Contacts, Browsing History, Health, Financial Info** — brak → nie.

## Krok 4 — Tracking
Nigdzie nie zaznaczaj „used for tracking".
W efekcie aplikacja **nie wymaga App Tracking Transparency** (brak ekranu „Allow to track").
Zgodne z rzeczywistością: brak reklam, brak data brokerów, brak łączenia z danymi third-party.

## Podsumowanie etykiety, jaka wyświetli się w App Store
- **Data Linked to You**: Email Address, User ID, User Content — used for App Functionality
- **Data Not Linked to You**: brak
- **Data Used to Track You**: brak

## Powiązane
- Privacy Policy URL (App Privacy → Privacy Policy URL): `https://www.530.pl/drinkotheque/privacy/`
- Źródło danych po stronie backendu: Supabase (region UE).
- Usuwanie konta z poziomu aplikacji: Szczegóły konta → „Usuń konto" (RPC `delete_user`).
