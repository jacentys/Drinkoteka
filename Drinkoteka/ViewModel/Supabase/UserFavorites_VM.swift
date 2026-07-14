// Ulubione drinki użytkownika synchronizowane z tabelą user_favorites (per konto).
// Obecność wiersza (user_id, drink_id) = drink jest ulubiony. Brak sesji → działa
// wyłącznie lokalnie na drUlubiony (bez zmian w Supabase).
import SwiftData
import Foundation

// MARK: - DTO

private struct UserFavoriteDTO: Codable {
    let drinkId: String

    enum CodingKeys: String, CodingKey {
        case drinkId = "drink_id"
    }
}

// MARK: - Zapis/usunięcie ulubionego

func setFavoriteInSupabase(drinkId: String, favorite: Bool) async {
    guard let userId = await AuthService_VM.shared.session?.user.id.uuidString else { return }
    do {
        if favorite {
            try await supabase
                .from("user_favorites")
                .upsert([
                    "user_id":  userId,
                    "drink_id": drinkId
                ])
                .execute()
        } else {
            try await supabase
                .from("user_favorites")
                .delete()
                .eq("user_id", value: userId)
                .eq("drink_id", value: drinkId)
                .execute()
        }
    } catch {
        dprint("Błąd zapisu ulubionego: \(error)")
    }
}

// MARK: - Ładowanie ulubionych po zalogowaniu

// Scala stan lokalny z serwerem: nigdy nie odznacza lokalnie ulubionego drinka
// (tylko dodaje z serwera), a lokalne ulubione nieznane jeszcze serwerowi
// (np. sprzed zalogowania) dopycha do Supabase, żeby nie zniknęły na innym urządzeniu.
func loadFavoritesFromSupabase(modelContext: ModelContext) async {
    guard await AuthService_VM.shared.isLoggedIn else { return }
    do {
        let favorites: [UserFavoriteDTO] = try await supabase
            .from("user_favorites")
            .select()
            .execute()
            .value
        let serverIds = Set(favorites.map { $0.drinkId })

        var doDopchniecia: [String] = []
        await MainActor.run {
            let drinks = (try? modelContext.fetch(FetchDescriptor<Dr_M>())) ?? []
            for drink in drinks {
                if serverIds.contains(drink.drinkID) {
                    drink.drUlubiony = true
                } else if drink.drUlubiony {
                    doDopchniecia.append(drink.drinkID)
                }
            }
            try? modelContext.save()
        }

        for drinkId in doDopchniecia {
            await setFavoriteInSupabase(drinkId: drinkId, favorite: true)
        }
    } catch is CancellationError {
        // Normalne: widok, który to wywołał, zniknął w trakcie (np. TabView
        // usunięty z hierarchii przy zmianie języka) — nie błąd.
    } catch {
        dprint("Błąd ładowania ulubionych: \(error)")
    }
}
