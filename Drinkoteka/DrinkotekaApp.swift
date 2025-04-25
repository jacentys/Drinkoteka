import SwiftUI
import SwiftData

@main
struct DrinkotekaApp: App {
    var body: some Scene {
		 
        WindowGroup {
			  CustomTab_V()
        }
		  .modelContainer(
			for: [Dr_M.self, Skl_M.self],
			inMemory: true,
			isUndoEnabled: true)
    }
}
