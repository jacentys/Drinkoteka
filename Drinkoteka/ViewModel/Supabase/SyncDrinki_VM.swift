import SwiftData
import Foundation

// MARK: - Synchronizacja drinków z Supabase
//
// Dane drinków są cache'owane lokalnie w SwiftData. Ta warstwa sprawdza,
// czy w bazie są drinki dostępne dla użytkownika, których nie ma lokalnie
// (nowe przepisy lub kategoria właśnie odblokowana), oraz po cichu usuwa
// drinki, do których użytkownik stracił dostęp (wylogowanie / cofnięcie
// uprawnień). RLS na tabeli `drinks` decyduje, które wiersze są widoczne.

private struct DrinkIDRow: Decodable {
    let id: String
}

// Zwraca zbiór ID drinków dostępnych dla bieżącej sesji (wg RLS).
func fetchAccessibleDrinkIDs() async throws -> Set<String> {
    let rows: [DrinkIDRow] = try await supabase
        .from("drinks")
        .select("id")
        .execute()
        .value
    return Set(rows.map { $0.id })
}

// Sprawdza aktualizacje:
// - po cichu usuwa lokalne drinki, do których nie ma już dostępu,
// - zwraca liczbę nowych drinków dostępnych do pobrania (nil = offline/błąd).
func sprawdzAktualizacjeDrinkow(modelContext: ModelContext) async -> Int? {
    guard let remoteIDs = try? await fetchAccessibleDrinkIDs() else { return nil }

    return await MainActor.run {
        let lokalne = (try? modelContext.fetch(FetchDescriptor<Dr_M>())) ?? []
        let lokalneIDs = Set(lokalne.map { $0.drinkID })

        // Usuń drinki bez dostępu (kaskada usuwa składniki i przepisy).
        // Wyjątek: własne drinki użytkownika (drZrodlo == "Własny") — ich nie ma
        // na serwerze, więc nie wolno ich kasować przy synchronizacji.
        let doUsuniecia = lokalne.filter { !remoteIDs.contains($0.drinkID) && $0.drZrodlo != "Własny" }
        for drink in doUsuniecia {
            modelContext.delete(drink)
        }
        if !doUsuniecia.isEmpty {
            try? modelContext.save()
        }

        // Nowe drinki = dostępne zdalnie, brak lokalnie
        return remoteIDs.subtracting(lokalneIDs).count
    }
}
