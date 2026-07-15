// Limit urządzeń na koncie (przeciwdziałanie współdzieleniu loginu/hasła).
// Każde urządzenie rejestruje się w user_devices przy odświeżeniu sesji;
// RLS pozwala dodać nowe urządzenie tylko do limitu (scripts/supabase_devices.sql).
// Po przekroczeniu limitu isPremium na nowym urządzeniu zostaje false,
// dopóki użytkownik nie usunie jednego ze starych urządzeń (Szczegóły konta).
import Foundation
#if canImport(UIKit)
import UIKit
#endif

let LIMIT_URZADZEN = 3

struct UrzadzenieDTO: Codable, Identifiable {
    let deviceId: String
    let deviceName: String?
    let lastSeen: String?

    var id: String { deviceId }

    enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case deviceName = "device_name"
        case lastSeen = "last_seen"
    }
}

func aktualneUrzadzenieId() -> String {
#if canImport(UIKit)
    return UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
#else
    return "unknown"
#endif
}

private func nazwaUrzadzenia() -> String {
#if canImport(UIKit)
    return UIDevice.current.name
#else
    return "Mac"
#endif
}

// Rejestruje to urządzenie na koncie (albo odświeża last_seen, jeśli już znane).
// Zwraca true, jeśli urządzenie jest autoryzowane (zarejestrowane albo pod limitem),
// false jeśli limit urządzeń na koncie został przekroczony.
@discardableResult
func registerDeviceInSupabase() async -> Bool {
    guard let userId = await AuthService_VM.shared.session?.user.id.uuidString else { return true }
    do {
        try await supabase
            .from("user_devices")
            .upsert([
                "user_id":     userId,
                "device_id":   aktualneUrzadzenieId(),
                "device_name": nazwaUrzadzenia(),
                "last_seen":   ISO8601DateFormatter().string(from: Date())
            ], onConflict: "user_id,device_id")
            .execute()
        return true
    } catch {
        dprint("[Devices] rejestracja odrzucona (limit \(LIMIT_URZADZEN) urządzeń?): \(error)")
        return false
    }
}

func listDevicesFromSupabase() async -> [UrzadzenieDTO] {
    do {
        let devices: [UrzadzenieDTO] = try await supabase
            .from("user_devices")
            .select()
            .order("last_seen", ascending: false)
            .execute()
            .value
        return devices
    } catch {
        dprint("[Devices] błąd listowania: \(error)")
        return []
    }
}

@discardableResult
func removeDeviceFromSupabase(deviceId: String) async -> Bool {
    guard let userId = await AuthService_VM.shared.session?.user.id.uuidString else { return false }
    do {
        try await supabase
            .from("user_devices")
            .delete()
            .eq("user_id", value: userId)
            .eq("device_id", value: deviceId)
            .execute()
        return true
    } catch {
        dprint("[Devices] błąd usuwania: \(error)")
        return false
    }
}
