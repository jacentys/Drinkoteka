#!/usr/bin/env python3
"""
Backup danych Supabase (Drinkoteka).

Zrzuca wszystkie publiczne tabele do plików JSON w katalogu z datą.
Razem z plikami schematu (supabase_schema.sql + supabase_new_tables.sql)
pozwala odtworzyć projekt od zera (patrz restore_supabase.py).

Wymaga klucza service_role (omija RLS) — czytany ze zmiennej
SUPABASE_SERVICE_KEY lub z pliku scripts/.supabase_service_key.

Użycie:
  python3 scripts/backup_supabase.py
  python3 scripts/backup_supabase.py --out /sciezka/do/backupu
"""

import argparse
import json
import os
import ssl
import sys
import urllib.request
import urllib.error
from datetime import datetime

SUPABASE_URL = os.environ.get("SUPABASE_URL", "https://beqxwdtkmzqonlsnbvlc.supabase.co")
KEY_FILE = os.path.join(os.path.dirname(__file__), ".supabase_service_key")

# Kolejność bezpieczna dla kluczy obcych (rodzice przed dziećmi) — użyta też przy restore.
TABLES = [
    "ingredients",
    "drinks",
    "ingredient_substitutes",
    "drink_ingredients",
    "drink_steps",
    "drink_spirits",
    "restricted_sources",
    "ingredient_translations",
    "drink_translations",
    "drink_step_translations",
    "drink_ingredient_translations",
    # Dane zależne od kont użytkowników (auth.users) — backup dla kompletności,
    # ale przy re-init na świeżym projekcie zwykle się ich nie przywraca.
    "profiles",
    "user_permissions",
    "user_notes",
    "redemption_codes",
    "code_redemptions",
    "drink_feedback",
    "app_feedback",
]

PAGE = 1000


def kontekst_ssl():
    try:
        import certifi
        return ssl.create_default_context(cafile=certifi.where())
    except ImportError:
        return ssl.create_default_context()


def wczytaj_service_key():
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


def fetch_all(table, key):
    """Pobiera wszystkie wiersze tabeli, stronicując po PAGE."""
    rows = []
    offset = 0
    while True:
        url = f"{SUPABASE_URL}/rest/v1/{table}?select=*&limit={PAGE}&offset={offset}"
        req = urllib.request.Request(url, headers={
            "apikey": key,
            "Authorization": f"Bearer {key}",
        })
        with urllib.request.urlopen(req, context=kontekst_ssl()) as resp:
            batch = json.loads(resp.read().decode("utf-8"))
        rows.extend(batch)
        if len(batch) < PAGE:
            break
        offset += PAGE
    return rows


def main():
    p = argparse.ArgumentParser(description="Backup danych Supabase do JSON.")
    p.add_argument("--out", default=None, help="Katalog docelowy (domyślnie scripts/backups/backup_<data>).")
    args = p.parse_args()

    key = wczytaj_service_key()
    if not key:
        print("BŁĄD: brak klucza service_role.\n"
              f"Ustaw SUPABASE_SERVICE_KEY lub zapisz klucz w:\n  {KEY_FILE}", file=sys.stderr)
        sys.exit(1)

    stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    out = args.out or os.path.join(os.path.dirname(__file__), "backups", f"backup_{stamp}")
    os.makedirs(out, exist_ok=True)

    manifest = {"created_at": datetime.now().isoformat(), "url": SUPABASE_URL, "tables": {}}
    for t in TABLES:
        try:
            rows = fetch_all(t, key)
        except urllib.error.HTTPError as e:
            print(f"  {t}: BŁĄD {e.code} (pomijam)", file=sys.stderr)
            manifest["tables"][t] = {"error": e.code}
            continue
        with open(os.path.join(out, f"{t}.json"), "w", encoding="utf-8") as fh:
            json.dump(rows, fh, ensure_ascii=False, indent=1)
        manifest["tables"][t] = {"rows": len(rows)}
        print(f"  {t}: {len(rows)} wierszy")

    with open(os.path.join(out, "manifest.json"), "w", encoding="utf-8") as fh:
        json.dump(manifest, fh, ensure_ascii=False, indent=2)

    print(f"\nBackup zapisany w: {out}")


if __name__ == "__main__":
    main()
