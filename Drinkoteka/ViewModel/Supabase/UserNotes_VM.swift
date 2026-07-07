import SwiftData
import Foundation

// MARK: - DTO

private struct UserNoteDTO: Codable {
    let userId: String
    let drinkId: String
    let note: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case drinkId = "drink_id"
        case note
    }
}

// MARK: - Zapis notatki

func saveNoteToSupabase(drinkId: String, note: String) async {
    guard let userId = await AuthService_VM.shared.session?.user.id.uuidString else { return }
    do {
        try await supabase
            .from("user_notes")
            .upsert([
                "user_id":    userId,
                "drink_id":   drinkId,
                "note":       note,
                "updated_at": ISO8601DateFormatter().string(from: Date())
            ])
            .execute()
    } catch {
        print("Błąd zapisu notatki: \(error)")
    }
}

// MARK: - Usunięcie notatki

func deleteNoteFromSupabase(drinkId: String) async {
    guard let userId = await AuthService_VM.shared.session?.user.id.uuidString else { return }
    do {
        try await supabase
            .from("user_notes")
            .delete()
            .eq("user_id", value: userId)
            .eq("drink_id", value: drinkId)
            .execute()
    } catch {
        print("Błąd usuwania notatki: \(error)")
    }
}

// MARK: - Ładowanie notatek po zalogowaniu

func loadNotesFromSupabase(modelContext: ModelContext) async {
    guard await AuthService_VM.shared.isLoggedIn else { return }
    do {
        let notes: [UserNoteDTO] = try await supabase
            .from("user_notes")
            .select()
            .execute()
            .value

        await MainActor.run {
            let drinks = (try? modelContext.fetch(FetchDescriptor<Dr_M>())) ?? []
            let drinkMap = Dictionary(uniqueKeysWithValues: drinks.map { ($0.drinkID, $0) })
            for noteDTO in notes {
                drinkMap[noteDTO.drinkId]?.drNotatka = noteDTO.note
            }
            try? modelContext.save()
        }
    } catch {
        print("Błąd ładowania notatek: \(error)")
    }
}
