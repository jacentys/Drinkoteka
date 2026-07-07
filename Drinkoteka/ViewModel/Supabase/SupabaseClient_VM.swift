// Globalny klient Supabase. Używa klucza ANON (publiczny, bezpieczny w kodzie).
// Klucz service_role NIGDY nie może się tu znaleźć.
import Supabase
import Foundation

let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://beqxwdtkmzqonlsnbvlc.supabase.co")!,
    supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJlcXh3ZHRrbXpxb25sc25idmxjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMzNDkxNjAsImV4cCI6MjA5ODkyNTE2MH0.UTMtNM3TJEoe_Biu3sz6zpkO9dw3e9gohVHeJpU-35I",
    options: SupabaseClientOptions(
        auth: SupabaseClientOptions.AuthOptions(
            emitLocalSessionAsInitialSession: true
        )
    )
)
