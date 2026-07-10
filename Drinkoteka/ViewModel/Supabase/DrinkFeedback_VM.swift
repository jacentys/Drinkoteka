// Wysyłka informacji zwrotnej: per-drink (drink_feedback) i ogólnej o aplikacji (app_feedback).
import Foundation

func sendDrinkFeedback(drinkId: String, feedback: String) async throws {
    let userId = await AuthService_VM.shared.session?.user.id.uuidString
    var payload: [String: String] = [
        "drink_id": drinkId,
        "feedback": feedback
    ]
    if let uid = userId { payload["user_id"] = uid }
    try await supabase
        .from("drink_feedback")
        .insert(payload)
        .execute()
}

// Ogólna informacja zwrotna o aplikacji (nie dotyczy konkretnego drinka).
func sendAppFeedback(feedback: String) async throws {
    let userId = await AuthService_VM.shared.session?.user.id.uuidString
    var payload: [String: String] = [
        "feedback": feedback
    ]
    if let uid = userId { payload["user_id"] = uid }
    try await supabase
        .from("app_feedback")
        .insert(payload)
        .execute()
}
