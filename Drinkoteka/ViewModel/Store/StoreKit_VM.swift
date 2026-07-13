// Zakupy Premium (subskrypcja) przez StoreKit 2.
// Weryfikacja i przyznanie premium odbywa się server-side (Supabase Edge Function
// "verify-subscription"), analogicznie do redeemCode — klient nigdy sam sobie
// nie ustawia is_premium.
import StoreKit
import Foundation
import Supabase

@MainActor
class StoreKit_VM: ObservableObject {
    static let shared = StoreKit_VM()

    static let monthlyID = "film.post.Drinkoteka.premium.monthly"
    static let yearlyID = "film.post.Drinkoteka.premium.yearly"

    @Published var products: [Product] = []
    @Published var isLoadingProducts: Bool = false
    @Published var isPurchasing: Bool = false
    @Published var errorMessage: String? = nil

    private var updatesTask: Task<Void, Never>? = nil

    private init() {
        updatesTask = listenForTransactionUpdates()
        Task { await loadProducts() }
    }

    deinit {
        updatesTask?.cancel()
    }

    // MARK: - Ładowanie produktów

    func loadProducts() async {
        isLoadingProducts = true
        do {
            let ids = [Self.monthlyID, Self.yearlyID]
            let fetched = try await Product.products(for: ids)
            // Rocznie przed miesięcznie w UI.
            products = fetched.sorted { lhs, rhs in
                lhs.id == Self.yearlyID && rhs.id != Self.yearlyID
            }
        } catch {
            dprint("[StoreKit] błąd ładowania produktów: \(error)")
            errorMessage = error.localizedDescription
        }
        isLoadingProducts = false
    }

    // MARK: - Zakup

    func purchase(_ product: Product) async {
        isPurchasing = true
        errorMessage = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await verifyOnServer(transaction, jws: verification.jwsRepresentation)
                await transaction.finish()
            case .userCancelled:
                break
            case .pending:
                break
            @unknown default:
                break
            }
        } catch {
            dprint("[StoreKit] błąd zakupu: \(error)")
            errorMessage = error.localizedDescription
        }
        isPurchasing = false
    }

    // MARK: - Przywracanie zakupów

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await AuthService_VM.shared.refreshPremiumStatus()
        } catch {
            dprint("[StoreKit] błąd przywracania zakupów: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Nasłuch aktualizacji transakcji (odnowienia, zmiany spoza apki)

    private func listenForTransactionUpdates() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self, let transaction = try? self.checkVerified(result) else { continue }
                await self.verifyOnServer(transaction, jws: result.jwsRepresentation)
                await transaction.finish()
            }
        }
    }

    // MARK: - Weryfikacja lokalna podpisu (StoreKit 2 JWS)

    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitVMError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Weryfikacja server-side + odświeżenie statusu Premium

    private func verifyOnServer(_ transaction: Transaction, jws: String) async {
        do {
            struct VerifyResponse: Decodable { let ok: Bool }
            let response: VerifyResponse = try await supabase.functions
                .invoke("verify-subscription", options: FunctionInvokeOptions(
                    body: ["signedTransaction": jws]
                ))
            if response.ok {
                await AuthService_VM.shared.refreshPremiumStatus()
            }
        } catch let FunctionsError.httpError(code, data) {
            let body = String(data: data, encoding: .utf8) ?? "?"
            dprint("[StoreKit] błąd weryfikacji server-side (\(code)): \(body)")
        } catch {
            dprint("[StoreKit] błąd weryfikacji server-side: \(error)")
        }
    }
}

enum StoreKitVMError: Error {
    case failedVerification
}
