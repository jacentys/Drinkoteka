// Stan posiadania składników (barek) użytkownika, synchronizowany z tabelą
// user_ingredient_stock (per konto). Obecność wiersza = składnik "jest" w barku.
// Stany pochodne (zmJest/zmBrak — dostępność przez zamiennik) NIE są
// synchronizowane wprost: przeliczają się lokalnie z surowego "jest" na każdym
// urządzeniu (recalculujStanyZamiennikow w Funkcje_VM.swift), bo zależą też od
// lokalnego ustawienia "zamiennikiDozwolone".
import SwiftData
import Foundation

// MARK: - DTO

private struct UserIngredientStockDTO: Codable {
    let ingredientId: String

    enum CodingKeys: String, CodingKey {
        case ingredientId = "ingredient_id"
    }
}

// MARK: - Zapis/usunięcie stanu składnika

func setIngredientStockInSupabase(ingredientId: String, owned: Bool) async {
    guard let userId = await AuthService_VM.shared.session?.user.id.uuidString else { return }
    do {
        if owned {
            try await supabase
                .from("user_ingredient_stock")
                .upsert([
                    "user_id":       userId,
                    "ingredient_id": ingredientId
                ])
                .execute()
        } else {
            try await supabase
                .from("user_ingredient_stock")
                .delete()
                .eq("user_id", value: userId)
                .eq("ingredient_id", value: ingredientId)
                .execute()
        }
    } catch {
        dprint("Błąd zapisu stanu składnika: \(error)")
    }
}

// MARK: - Ładowanie stanu składników po zalogowaniu

// Scala stan lokalny z serwerem: nigdy nie odznacza lokalnie posiadanego
// składnika (tylko dodaje z serwera), a lokalne "jest" nieznane jeszcze
// serwerowi (np. sprzed zalogowania) dopycha do Supabase.
func loadIngredientStockFromSupabase(modelContext: ModelContext) async {
    guard await AuthService_VM.shared.isLoggedIn else { return }
    do {
        let stock: [UserIngredientStockDTO] = try await supabase
            .from("user_ingredient_stock")
            .select()
            .execute()
            .value
        let ownedIds = Set(stock.map { $0.ingredientId })

        var doDopchniecia: [String] = []
        await MainActor.run {
            let skladniki = (try? modelContext.fetch(FetchDescriptor<Skl_M>())) ?? []
            for skladnik in skladniki {
                if ownedIds.contains(skladnik.sklID) {
                    skladnik.sklStan = .jest
                } else if skladnik.sklStan == .jest {
                    doDopchniecia.append(skladnik.sklID)
                }
            }
            recalculujStanyZamiennikow(modelContext: modelContext)
            try? modelContext.save()
        }

        for ingredientId in doDopchniecia {
            await setIngredientStockInSupabase(ingredientId: ingredientId, owned: true)
        }
    } catch is CancellationError {
        // Normalne: widok, który to wywołał, zniknął w trakcie (np. TabView
        // usunięty z hierarchii przy zmianie języka) — nie błąd.
    } catch {
        dprint("Błąd ładowania stanu składników: \(error)")
    }
}
