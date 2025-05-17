import SwiftUI
import SwiftData

@main
struct DrinkotekaApp: App {

	@AppStorage("blokujEkran") var blokujEkran: Bool = false

    var body: some Scene {
		 
        WindowGroup {
			  CustomTab_V()
				  .onAppear {
						  // Disable the idle timer when the view appears
					  UIApplication.shared.isIdleTimerDisabled = blokujEkran
				  }
				  .onDisappear {
						  // Re-enable the idle timer when the view disappears
					  UIApplication.shared.isIdleTimerDisabled = blokujEkran
				  }
        }
		  .modelContainer(
			for: [Dr_M.self, Skl_M.self],
			inMemory: false,
			isUndoEnabled: false)
    }
}
