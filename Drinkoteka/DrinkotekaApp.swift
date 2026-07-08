// Punkt wejścia aplikacji. Rejestruje kontener SwiftData (Dr_M, Skl_M),
// ustawia URLCache dla obrazów i język/locale UI.
import SwiftUI
import SwiftData

@main
struct DrinkotekaApp: App {

	@Environment(\.scenePhase) private var scenePhase
	@AppStorage("blokujEkran") var blokujEkran: Bool = false
	@AppStorage("jezykAplikacji") var jezykAplikacji: String = {
		let kod = Locale.current.language.languageCode?.identifier ?? "en"
		return kod == "pl" ? "pl" : "en"
	}()

    init() {
        // URLCache: 50 MB RAM, 200 MB dysk
        URLCache.shared = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity:  200 * 1024 * 1024
        )
    }

    var body: some Scene {
		 
        WindowGroup {
			  CustomTab_V()
				  .id(jezykAplikacji)
				  .environment(\.locale, Locale(identifier: jezykAplikacji))
				  // „Nie wygaszaj ekranu" — flaga stosowana reaktywnie:
				  // przy starcie, po zmianie ustawienia oraz po powrocie z tła
				  // (iOS potrafi zresetować isIdleTimerDisabled przy przejściu w tło).
				  .onAppear {
					  UIApplication.shared.isIdleTimerDisabled = blokujEkran
				  }
				  .onChange(of: blokujEkran) { _, nowy in
					  UIApplication.shared.isIdleTimerDisabled = nowy
				  }
				  .onChange(of: scenePhase) { _, faza in
					  if faza == .active {
						  UIApplication.shared.isIdleTimerDisabled = blokujEkran
					  }
				  }
				  // Deep link po potwierdzeniu maila (drinkoteka://login-callback)
				  .onOpenURL { url in
					  Task { await AuthService_VM.shared.handleDeepLink(url) }
				  }
        }
		  .modelContainer(
			for: [Dr_M.self, Skl_M.self],
			inMemory: false,
			isUndoEnabled: false)
    }
}
