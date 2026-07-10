#!/usr/bin/env python3
"""
Przywracanie danych Supabase (Drinkoteka) z backupu JSON.

Wgrywa dane z katalogu backupu (backup_supabase.py) do bazy metodą upsert
(POST + Prefer: resolution=merge-duplicates — PostgREST sam używa klucza głównego).

WAŻNE: najpierw musi istnieć SCHEMAT bazy. Na świeżym projekcie uruchom w SQL Editor:
  1) supabase_schema.sql         (tabele bazowe + funkcje)
  2) supabase_new_tables.sql     (nowe tabele, RLS, funkcje)
a dopiero potem ten skrypt (dane).

Wymaga klucza service_role (SUPABASE_SERVICE_KEY lub scripts/.supabase_service_key).

Użycie:
  python3 scripts/restore_supabase.py scripts/backups/backup_20260707_2200
  python3 scripts/restore_supabase.py <katalog> --skip-user-data
"""

import argparse
import json
import os
import ssl
import sys
import urllib.request
import urllib.error

SUPABASE_URL = os.environ.get("SUPABASE_URL", "https://beqxwdtkmzqonlsnbvlc.supabase.co")
KEY_FILE = os.path.join(os.path.dirname(__file__), ".supabase_service_key")

# Ta sama kolejność FK-safe co w backupie.
ORDER = [
    "ingredients", "drinks", "ingredient_substitutes", "drink_ingredients",
    "drink_steps", "drink_spirits", "restricted_sources",
    "ingredient_translations", "drink_translations",
    "drink_step_translations", "drink_ingredient_translations",
    "profiles", "user_permissions", "user_notes",
    "redemption_codes", "code_redemptions", "drink_feedback", "app_feedback",
]

# Tabele zależne od kont użytkowników — pomijane przez --skip-user-data.
USER_DATA = {"profiles", "user_permissions", "user_notes", "code_redemptions",
             "drink_feedback", "app_feedback"}

BATCH = 500


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


def upsert(table, rows, key):
    url = f"{SUPABASE_URL}/rest/v1/{table}"
    for i in range(0, len(rows), BATCH):
        chunk = rows[i:i + BATCH]
        body = json.dumps(chunk).encode("utf-8")
        req = urllib.request.Request(url, data=body, method="POST", headers={
            "apikey": key,
            "Authorization": f"Bearer {key}",
            "Content-Type": "application/json",
            "Prefer": "resolution=merge-duplicates,return=minimal",
        })
        with urllib.request.urlopen(req, context=kontekst_ssl()):
            pass


def main():
    p = argparse.ArgumentParser(description="Przywracanie danych Supabase z backupu JSON.")
    p.add_argument("katalog", help="Katalog backupu (z plikami <tabela>.json).")
    p.add_argument("--skip-user-data", action="store_true",
                   help="Pomiń dane zależne od kont (profiles, user_permissions, notatki, kody-użycia, feedback).")
    args = p.parse_args()

    key = wczytaj_service_key()
    if not key:
        print(f"BŁĄD: brak klucza service_role (SUPABASE_SERVICE_KEY lub {KEY_FILE}).", file=sys.stderr)
        sys.exit(1)
    if not os.path.isdir(args.katalog):
        print(f"BŁĄD: nie ma katalogu {args.katalog}", file=sys.stderr)
        sys.exit(1)

    for t in ORDER:
        if args.skip_user_data and t in USER_DATA:
            print(f"  {t}: pominięto (--skip-user-data)")
            continue
        path = os.path.join(args.katalog, f"{t}.json")
        if not os.path.exists(path):
            continue
        rows = json.load(open(path, encoding="utf-8"))
        if not rows:
            print(f"  {t}: 0 wierszy"); continue
        try:
            upsert(t, rows, key)
            print(f"  {t}: przywrócono {len(rows)}")
        except urllib.error.HTTPError as e:
            print(f"  {t}: BŁĄD {e.code}: {e.read().decode('utf-8','replace')[:200]}", file=sys.stderr)

    print("\nGotowe.")


if __name__ == "__main__":
    main()
