// Edge Function: weryfikuje transakcję StoreKit 2 (JWS) przez App Store Server API
// i na tej podstawie ustawia is_premium/premium_expires_at w profiles (service_role,
// klient nigdy nie ustawia tego sam — patrz RLS w scripts/supabase_new_tables.sql).
//
// Wymagane sekrety (supabase secrets set ...):
//   SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY  (dostępne domyślnie w Edge Functions)
//   APPLE_IAP_KEY_ID          — Key ID klucza In-App Purchase z App Store Connect
//   APPLE_IAP_ISSUER_ID       — Issuer ID (Users and Access → Integrations)
//   APPLE_BUNDLE_ID           — film.post.Drinkoteka
//   APPLE_IAP_PRIVATE_KEY     — zawartość pliku .p8 (PEM, z nagłówkami BEGIN/END)

import { createClient } from "npm:@supabase/supabase-js@2";
import { SignJWT, importPKCS8, decodeJwt } from "npm:jose@5";

const APPLE_KEY_ID = Deno.env.get("APPLE_IAP_KEY_ID")!;
const APPLE_ISSUER_ID = Deno.env.get("APPLE_IAP_ISSUER_ID")!;
const APPLE_BUNDLE_ID = Deno.env.get("APPLE_BUNDLE_ID")!;
const APPLE_PRIVATE_KEY_PEM = Deno.env.get("APPLE_IAP_PRIVATE_KEY")!;

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;

// Buduje krótkotrwały JWT (ES256) do autoryzacji wywołań App Store Server API.
async function buildAppleServerToken(): Promise<string> {
  const key = await importPKCS8(APPLE_PRIVATE_KEY_PEM, "ES256");
  const now = Math.floor(Date.now() / 1000);
  return await new SignJWT({
    bid: APPLE_BUNDLE_ID,
  })
    .setProtectedHeader({ alg: "ES256", kid: APPLE_KEY_ID, typ: "JWT" })
    .setIssuer(APPLE_ISSUER_ID)
    .setIssuedAt(now)
    .setExpirationTime(now + 1200) // max 60 min wg Apple, zostajemy przy 20 min
    .setAudience("appstoreconnect-v1")
    .sign(key);
}

async function fetchTransactionInfo(transactionId: string, appleToken: string) {
  const headers = { Authorization: `Bearer ${appleToken}` };

  // Najpierw produkcja; przy 404 (transakcja sandboxowa) lub 401 (Apple czasem
  // odrzuca sandboxowe transakcje na endpointcie produkcyjnym jako nieautoryzowane
  // zamiast zwrócić 404) — spróbuj sandboxa.
  let res = await fetch(
    `https://api.storekit.itunes.apple.com/inApps/v1/transactions/${transactionId}`,
    { headers }
  );
  if (res.status === 404 || res.status === 401) {
    res = await fetch(
      `https://api.storekit-sandbox.itunes.apple.com/inApps/v1/transactions/${transactionId}`,
      { headers }
    );
  }
  if (!res.ok) {
    throw new Error(`App Store Server API error: ${res.status} ${await res.text()}`);
  }
  const json = await res.json();
  // signedTransactionInfo to kolejny JWS podpisany przez Apple — bezpieczny do
  // odczytania bez ponownej weryfikacji podpisu, bo dotarł do nas przez uwierzytelnione
  // (naszym kluczem) połączenie z serwerem Apple, a nie od klienta.
  return decodeJwt(json.signedTransactionInfo) as {
    transactionId: string;
    originalTransactionId: string;
    productId: string;
    expiresDate?: number;
    revocationDate?: number;
  };
}

Deno.serve(async (req) => {
  try {
    const authHeader = req.headers.get("Authorization") ?? "";
    const userClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: userData, error: userError } = await userClient.auth.getUser();
    if (userError || !userData?.user) {
      return new Response(JSON.stringify({ ok: false, error: "not_authenticated" }), { status: 401 });
    }
    const userId = userData.user.id;

    const { signedTransaction } = await req.json();
    if (!signedTransaction || typeof signedTransaction !== "string") {
      return new Response(JSON.stringify({ ok: false, error: "missing_signed_transaction" }), { status: 400 });
    }

    // Odczyt transactionId z payloadu klienta tylko po to, by wiedzieć KOGO zapytać
    // Apple — nie ufamy tu żadnym innym polom, dopóki nie potwierdzi ich Apple.
    const unverified = decodeJwt(signedTransaction) as { transactionId?: string };
    if (!unverified.transactionId) {
      return new Response(JSON.stringify({ ok: false, error: "invalid_transaction" }), { status: 400 });
    }

    const appleToken = await buildAppleServerToken();
    const info = await fetchTransactionInfo(unverified.transactionId, appleToken);

    const now = Date.now();
    const isActive = !!info.expiresDate && info.expiresDate > now && !info.revocationDate;

    const admin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
    const { error: updateError } = await admin
      .from("profiles")
      .update({
        is_premium: isActive,
        premium_product_id: info.productId,
        premium_expires_at: info.expiresDate ? new Date(info.expiresDate).toISOString() : null,
        premium_original_transaction_id: info.originalTransactionId,
        premium_auto_renew: isActive,
        updated_at: new Date().toISOString(),
      })
      .eq("user_id", userId);

    if (updateError) {
      return new Response(JSON.stringify({ ok: false, error: updateError.message }), { status: 500 });
    }

    return new Response(JSON.stringify({ ok: true }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ ok: false, error: String(error) }), { status: 500 });
  }
});
