// Centralny serwis auth i uprawnień (singleton, @MainActor).
// Sesja, Premium, uprawnienia do kategorii, blokowane źródła, realizacja kodów aktywacyjnych.
import Supabase
import SwiftUI

@MainActor
class AuthService_VM: ObservableObject {
    static let shared = AuthService_VM()

    @Published var session: Session? = nil
    @Published var isLoading: Bool = false
    @Published var isRefreshing: Bool = true
    @Published var errorMessage: String? = nil
    @Published var oczekujeNaPotwierdzenieMaila: Bool = false
    @Published var isPremium: Bool = false
    @Published var permissions: Set<String> = []
    @Published var restrictedSources: [RestrictedSource] = []

    struct RestrictedSource: Decodable, Identifiable {
        let source: String
        let permission: String
        var id: String { source }
    }

    var isLoggedIn: Bool { session != nil }
    var userEmail: String { session?.user.email ?? "" }

    private init() {
        Task { await refreshSession() }
    }

    // MARK: - Odświeżenie sesji przy starcie

    func refreshSession() async {
        isRefreshing = true
        do {
            session = try await supabase.auth.session
            await refreshPremiumStatus()
            await refreshPermissions()
            await refreshRestrictedSources()
        } catch {
            session = nil
            isPremium = false
            permissions = []
            await refreshRestrictedSources()
        }
        isRefreshing = false
    }

    // MARK: - Status premium

    func refreshPremiumStatus() async {
        guard session != nil else { isPremium = false; return }
        do {
            struct ProfileDTO: Decodable {
                let isPremium: Bool
                enum CodingKeys: String, CodingKey { case isPremium = "is_premium" }
            }
            let profile: ProfileDTO = try await supabase
                .from("profiles")
                .select("is_premium")
                .single()
                .execute()
                .value
            isPremium = profile.isPremium
            dprint("[Premium] isPremium = \(isPremium)")
        } catch {
            dprint("[Premium] błąd: \(error)")
            isPremium = false
        }
    }

    // MARK: - Pozwolenia na kategorie

    func refreshPermissions() async {
        guard session != nil else { permissions = []; return }
        do {
            struct PermissionDTO: Decodable {
                let permission: String
            }
            let rows: [PermissionDTO] = try await supabase
                .from("user_permissions")
                .select("permission")
                .execute()
                .value
            permissions = Set(rows.map { $0.permission })
        } catch {
            permissions = []
        }
    }

    func hasPermission(_ permission: String) -> Bool {
        permissions.contains(permission)
    }

    // Pobiera mapowanie źródło→pozwolenie z tabeli restricted_sources (publiczny odczyt).
    func refreshRestrictedSources() async {
        do {
            let rows: [RestrictedSource] = try await supabase
                .from("restricted_sources")
                .select("source, permission")
                .execute()
                .value
            restrictedSources = rows
        } catch {
            restrictedSources = []
        }
    }

    // Czy użytkownik ma dostęp do drinków z danego źródła (drZrodlo).
    func maDostepDoZrodla(_ zrodlo: String) -> Bool {
        guard let rs = restrictedSources.first(where: { $0.source == zrodlo }) else { return true }
        return permissions.contains(rs.permission)
    }

    func canAccessDrink(_ drink: Dr_M) -> Bool {
        maDostepDoZrodla(drink.drZrodlo)
    }

    // Czy użytkownik może OTWORZYĆ przepis drinka. Trzy poziomy:
    // 1) IBA — darmowe dla każdego,
    // 2) kategoria specjalna (restricted_sources) — decyduje kod kategorii (nie Premium),
    // 3) zwykłe nie-IBA — wymaga Premium.
    func mozeOtworzyc(_ drink: Dr_M) -> Bool {
        if drink.czyIBA { return true }
        if let rs = restrictedSources.first(where: { $0.source == drink.drZrodlo }) {
            return permissions.contains(rs.permission)
        }
        return isPremium
    }

    // Blokowane kategorie, do których użytkownik MA dostęp.
    // Tylko te pokazujemy w profilu — użytkownik nie powinien wiedzieć o istnieniu
    // kategorii, do których nie ma dostępu.
    var dostepneKategorie: [String] {
        restrictedSources
            .filter { permissions.contains($0.permission) }
            .map { $0.source }
            .sorted()
    }

    // MARK: - Kod aktywacyjny

    // Realizuje kod przez funkcję redeem_code na serwerze.
    // Zwraca: ok / invalid / expired / wrong_account / already_used / exhausted / not_logged_in / error
    func redeemCode(_ code: String) async -> String {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "invalid" }
        do {
            let result: String = try await supabase
                .rpc("redeem_code", params: ["p_code": trimmed])
                .execute()
                .value
            if result == "ok" {
                await refreshPremiumStatus()
                await refreshPermissions()
            }
            return result
        } catch {
            dprint("[Kod] błąd: \(error)")
            return "error"
        }
    }

    // MARK: - Deep link (potwierdzenie maila / callback auth)

    // Wywoływane z .onOpenURL, gdy system otworzy aplikację linkiem drinkoteka://...
    // Ustanawia sesję z tokenów przekazanych w URL po potwierdzeniu maila.
    func handleDeepLink(_ url: URL) async {
        do {
            try await supabase.auth.session(from: url)
            await refreshSession()
        } catch {
            dprint("[Auth] deep link error: \(error)")
        }
    }

    // MARK: - Rejestracja

    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        oczekujeNaPotwierdzenieMaila = false
        do {
            dprint("[Auth] signUp start: \(email)")
            // redirectTo: po kliknięciu linku potwierdzającego Supabase przekieruje
            // do deep linku aplikacji (schemat drinkoteka://), a nie na localhost.
            let result = try await supabase.auth.signUp(
                email: email,
                password: password,
                redirectTo: URL(string: "drinkoteka://login-callback")
            )
            dprint("[Auth] signUp result — session: \(result.session != nil ? "TAK" : "NIL"), user: \(result.user.email ?? "?")")
            if let s = result.session {
                session = s
            } else {
                oczekujeNaPotwierdzenieMaila = true
            }
        } catch {
            dprint("[Auth] signUp error: \(error)")
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Logowanie

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await supabase.auth.signIn(email: email, password: password)
            session = result
            await refreshPremiumStatus()
            await refreshPermissions()
            await refreshRestrictedSources()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Zmiana hasła

    func changePassword(noweHaslo: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await supabase.auth.update(user: UserAttributes(password: noweHaslo))
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Usunięcie konta

    func deleteAccount() async {
        isLoading = true
        errorMessage = nil
        do {
            // Wywołuje Edge Function lub RPC do usunięcia konta (wymaga service_role po stronie serwera)
            try await supabase.rpc("delete_user").execute()
            try await supabase.auth.signOut()
            session = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Wylogowanie

    func signOut() async {
        isLoading = true
        do {
            try await supabase.auth.signOut()
            session = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
