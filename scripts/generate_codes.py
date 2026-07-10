#!/usr/bin/env python3
"""
Generator kodów aktywacyjnych dla Drinkoteki.

Tworzy losowe kody i wypisuje gotowe instrukcje INSERT do wklejenia
w Supabase SQL Editor. Nie wymaga klucza service_role.

Przykłady:
  # 5 kodów Premium (dowolne konto, domyślnie do 2 użyć):
  python3 scripts/generate_codes.py --type premium --count 5

  # kod na kategorię, przypisany do konkretnego maila:
  python3 scripts/generate_codes.py --type permission \
      --value category:przepisy_na_proste_drinki \
      --email jacek@skrobisz.com --prefix KLASYKI

  # 10 kodów promocyjnych Premium ważnych 30 dni:
  python3 scripts/generate_codes.py --type premium --count 10 --expires-days 30 --prefix PROMO

  # zapis do pliku zamiast na ekran:
  python3 scripts/generate_codes.py --type premium --count 100 --out kody.sql
"""

import argparse
import json
import os
import secrets
import ssl
import sys
import urllib.request
import urllib.error
import urllib.parse
from datetime import datetime, timedelta, timezone


def kontekst_ssl():
    """Zwraca kontekst SSL z weryfikacją certyfikatu.
    Na macOS Python z python.org nie korzysta z keychaina, więc używamy
    pakietu certifi. Weryfikacji NIE wyłączamy — wysyłamy tu klucz service_role."""
    try:
        import certifi
        return ssl.create_default_context(cafile=certifi.where())
    except ImportError:
        # Spróbuj domyślnego magazynu (zadziała, jeśli certyfikaty są zainstalowane)
        return ssl.create_default_context()

# Alfabet bez znaków dwuznacznych (brak 0/O/1/I/L)
ALPHABET = "ABCDEFGHJKMNPQRSTUVWXYZ23456789"

# URL projektu Supabase (można nadpisać zmienną SUPABASE_URL)
SUPABASE_URL = os.environ.get("SUPABASE_URL", "https://beqxwdtkmzqonlsnbvlc.supabase.co")

# Ścieżka do lokalnego pliku z kluczem service_role (poza repo, w .gitignore)
KEY_FILE = os.path.join(os.path.dirname(__file__), ".supabase_service_key")


def wczytaj_service_key():
    """Klucz service_role: najpierw zmienna środowiskowa, potem lokalny plik.
    W pliku pomijane są puste linie i komentarze (#) — brany jest pierwszy
    niepusty wiersz z treścią."""
    key = os.environ.get("SUPABASE_SERVICE_KEY")
    if key and key.strip():
        return key.strip()
    if os.path.exists(KEY_FILE):
        with open(KEY_FILE, encoding="utf-8") as fh:
            for line in fh:
                line = line.strip()
                if line and not line.startswith("#"):
                    return line
    return None


def wstaw_do_bazy(rows, key):
    """Wstawia wiersze do redemption_codes przez REST API (service_role)."""
    url = f"{SUPABASE_URL}/rest/v1/redemption_codes"
    body = json.dumps(rows).encode("utf-8")
    req = urllib.request.Request(url, data=body, method="POST", headers={
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
        "Prefer": "return=minimal",
    })
    return _zadanie(req)


def revoke_codes(codes, key):
    """Usuwa kody z redemption_codes (kaskadowo znika też historia użyć)."""
    lista = ",".join(urllib.parse.quote(c) for c in codes)
    url = f"{SUPABASE_URL}/rest/v1/redemption_codes?code=in.({lista})"
    req = urllib.request.Request(url, method="DELETE", headers={
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Prefer": "return=representation",
    })
    return _zadanie(req, parse_json=True)


def list_categories(key):
    """Zwraca blokowane kategorie (source → wymagane uprawnienie)."""
    url = (f"{SUPABASE_URL}/rest/v1/restricted_sources"
           "?select=source,permission&order=source.asc")
    req = urllib.request.Request(url, method="GET", headers={
        "apikey": key,
        "Authorization": f"Bearer {key}",
    })
    return _zadanie(req, parse_json=True)


def list_codes(key):
    """Zwraca listę kodów wraz z wykorzystaniem."""
    url = (f"{SUPABASE_URL}/rest/v1/redemption_codes"
           "?select=code,reward_type,reward_value,bound_email,used_count,max_uses,expires_at"
           "&order=created_at.desc")
    req = urllib.request.Request(url, method="GET", headers={
        "apikey": key,
        "Authorization": f"Bearer {key}",
    })
    return _zadanie(req, parse_json=True)


def _zadanie(req, parse_json=False):
    """Wysyła żądanie z weryfikacją SSL i mapuje błędy na czytelne komunikaty."""
    try:
        with urllib.request.urlopen(req, context=kontekst_ssl()) as resp:
            if parse_json:
                raw = resp.read().decode("utf-8")
                return True, (json.loads(raw) if raw.strip() else [])
            return True, resp.status
    except urllib.error.HTTPError as e:
        return False, f"{e.code}: {e.read().decode('utf-8', 'replace')}"
    except ssl.SSLError as e:
        return False, ("błąd SSL — zainstaluj certyfikaty: `pip3 install certifi` "
                       "lub uruchom „Install Certificates.command” z katalogu Pythona. "
                       f"Szczegóły: {e}")
    except urllib.error.URLError as e:
        reason = getattr(e, "reason", e)
        if isinstance(reason, ssl.SSLCertVerificationError):
            return False, ("błąd weryfikacji certyfikatu SSL — zainstaluj certyfikaty: "
                           "`pip3 install certifi` lub uruchom „Install Certificates.command”.")
        return False, str(reason)


def losowy_segment(dlugosc: int) -> str:
    return "".join(secrets.choice(ALPHABET) for _ in range(dlugosc))


def zbuduj_kod(prefix: str, dlugosc: int) -> str:
    rdzen = losowy_segment(dlugosc)
    return f"{prefix.upper()}-{rdzen}" if prefix else rdzen


def sql_str(s):
    if s is None:
        return "NULL"
    return "'" + str(s).replace("'", "''") + "'"


def _wymagany_klucz():
    key = wczytaj_service_key()
    if not key:
        print("BŁĄD: brak klucza service_role.\n"
              f"Ustaw zmienną SUPABASE_SERVICE_KEY lub zapisz klucz w pliku:\n  {KEY_FILE}",
              file=sys.stderr)
        sys.exit(1)
    return key


def tryb_list():
    ok, data = list_codes(_wymagany_klucz())
    if not ok:
        print(f"BŁĄD: {data}", file=sys.stderr)
        sys.exit(1)
    if not data:
        print("Brak kodów w bazie.")
        return
    print(f"{'KOD':<20} {'TYP':<11} {'UŻYCIA':<7} {'MAIL':<28} WYGASA")
    for r in data:
        uz = f"{r.get('used_count',0)}/{r.get('max_uses','?')}"
        exp = (r.get("expires_at") or "")[:10] or "-"
        val = r.get("reward_value") or r.get("reward_type", "")
        print(f"{r['code']:<20} {val[:11]:<11} {uz:<7} {(r.get('bound_email') or '-'):<28} {exp}")


def tryb_list_categories():
    ok, data = list_categories(_wymagany_klucz())
    if not ok:
        print(f"BŁĄD: {data}", file=sys.stderr)
        sys.exit(1)
    if not data:
        print("Brak blokowanych kategorii (restricted_sources jest pusta).")
        return
    print(f"{'KATEGORIA (source)':<34} UPRAWNIENIE (--value)")
    for r in data:
        print(f"{r['source']:<34} {r['permission']}")


def tryb_revoke(codes):
    ok, data = revoke_codes(codes, _wymagany_klucz())
    if not ok:
        print(f"BŁĄD: {data}", file=sys.stderr)
        sys.exit(1)
    usuniete = [r["code"] for r in data] if isinstance(data, list) else []
    if not usuniete:
        print("Nie usunięto żadnego kodu (być może nie istnieją).")
        return
    print(f"Usunięto {len(usuniete)} kod(ów):")
    for c in usuniete:
        print(f"  {c}")
    print("\nUwaga: już przyznane nagrody (premium/uprawnienia) pozostają u użytkowników.")


def main():
    p = argparse.ArgumentParser(description="Generator kodów aktywacyjnych Drinkoteki.")
    p.add_argument("--type", choices=["premium", "permission"], default=None,
                   help="Rodzaj nagrody (wymagane przy generowaniu).")
    p.add_argument("--value", default=None,
                   help="Dla 'permission': wartość uprawnienia, np. category:przepisy_na_proste_drinki.")
    p.add_argument("--email", default=None,
                   help="Przypisz kod do konkretnego maila (opcjonalnie).")
    p.add_argument("--count", type=int, default=1, help="Ile kodów wygenerować.")
    p.add_argument("--uses", type=int, default=2, help="Maks. liczba użyć na kod (domyślnie 2).")
    p.add_argument("--expires-days", type=int, default=None,
                   help="Wygaśnięcie za N dni (opcjonalnie).")
    p.add_argument("--prefix", default=None,
                   help="Prefiks kodu (domyślnie zależny od typu, np. PREMIUM).")
    p.add_argument("--length", type=int, default=6, help="Długość losowej części kodu.")
    p.add_argument("--out", default=None, help="Zapisz SQL do pliku zamiast na ekran.")
    p.add_argument("--insert", action="store_true",
                   help="Wstaw kody bezpośrednio do bazy (wymaga klucza service_role).")
    p.add_argument("--revoke", nargs="+", metavar="KOD",
                   help="Usuń podane kody z bazy (wymaga klucza service_role).")
    p.add_argument("--list", action="store_true",
                   help="Wypisz wszystkie kody i ich wykorzystanie (wymaga klucza service_role).")
    p.add_argument("--list-categories", action="store_true",
                   help="Wypisz blokowane kategorie i ich uprawnienia (--value).")
    args = p.parse_args()

    # --- Tryby zarządzania (nie generują nowych kodów) ---
    if args.list_categories:
        return tryb_list_categories()
    if args.list:
        return tryb_list()
    if args.revoke:
        return tryb_revoke(args.revoke)

    # --- Walidacja generowania ---
    if not args.type:
        p.error("--type jest wymagane przy generowaniu kodów.")
    if args.type == "permission" and not args.value:
        p.error("--value jest wymagane dla --type permission (np. category:...).")
    if args.count < 1:
        p.error("--count musi być >= 1.")

    prefix = args.prefix if args.prefix is not None else ("PREMIUM" if args.type == "premium" else "CODE")
    reward_value = args.value if args.type == "permission" else None

    expires = None
    if args.expires_days is not None:
        expires = (datetime.now(timezone.utc) + timedelta(days=args.expires_days)).isoformat()

    # Generuj unikalne kody
    kody = set()
    while len(kody) < args.count:
        kody.add(zbuduj_kod(prefix, args.length))
    kody = sorted(kody)

    # --- Tryb 1: wstawienie bezpośrednio do bazy ---
    if args.insert:
        key = wczytaj_service_key()
        if not key:
            print("BŁĄD: brak klucza service_role.\n"
                  f"Ustaw zmienną SUPABASE_SERVICE_KEY lub zapisz klucz w pliku:\n  {KEY_FILE}",
                  file=sys.stderr)
            sys.exit(1)
        rows = [{
            "code": kod,
            "reward_type": args.type,
            "reward_value": reward_value,
            "bound_email": args.email,
            "max_uses": args.uses,
            "expires_at": expires,
        } for kod in kody]
        ok, info = wstaw_do_bazy(rows, key)
        if not ok:
            print(f"BŁĄD zapisu do bazy: {info}", file=sys.stderr)
            sys.exit(1)
        print(f"Zapisano {len(kody)} kod(ów) do bazy. Wygenerowane kody:", file=sys.stderr)
        for kod in kody:
            print(f"  {kod}", file=sys.stderr)
        # Na stdout tylko czyste kody (łatwe do skopiowania / przekazania)
        print("\n".join(kody))
        return

    # --- Tryb 2 (domyślny): wypisz SQL do wklejenia w SQL Editor ---
    linie = [
        "-- Kody aktywacyjne Drinkoteki — wklej w Supabase SQL Editor.",
        f"-- typ: {args.type}"
        + (f", wartość: {reward_value}" if reward_value else "")
        + (f", mail: {args.email}" if args.email else ", mail: dowolny")
        + f", maks. użyć: {args.uses}"
        + (f", wygasa: {args.expires_days} dni" if args.expires_days else ""),
        "",
    ]
    for kod in kody:
        linie.append(
            "insert into redemption_codes "
            "(code, reward_type, reward_value, bound_email, max_uses, expires_at) values ("
            f"{sql_str(kod)}, {sql_str(args.type)}, {sql_str(reward_value)}, "
            f"{sql_str(args.email)}, {args.uses}, {sql_str(expires)});"
        )
    sql = "\n".join(linie) + "\n"

    if args.out:
        with open(args.out, "w", encoding="utf-8") as fh:
            fh.write(sql)
        print(f"Zapisano {len(kody)} kodów do: {args.out}", file=sys.stderr)

    # Lista kodów do rozdania (na stderr, żeby nie mieszać z SQL przy > out)
    print("\nWygenerowane kody:", file=sys.stderr)
    for kod in kody:
        print(f"  {kod}", file=sys.stderr)

    if not args.out:
        print("\n" + sql)


if __name__ == "__main__":
    main()
