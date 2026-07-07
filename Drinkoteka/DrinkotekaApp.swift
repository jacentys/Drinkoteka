import SwiftUI
import SwiftData

@main
struct DrinkotekaApp: App {

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
				  .onAppear {
					  UIApplication.shared.isIdleTimerDisabled = blokujEkran
				  }
				  .onDisappear {
					  UIApplication.shared.isIdleTimerDisabled = blokujEkran
				  }
        }
		  .modelContainer(
			for: [Dr_M.self, Skl_M.self],
			inMemory: false,
			isUndoEnabled: false)
    }
}
