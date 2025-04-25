import SwiftUI

struct ContentView: View {
	@State private var searchText = ""
	@State private var selectedItem: String? = "Wiadomość 1"
	let items = ["Wiadomość 1", "Wiadomość 2", "Wiadomość 3"]

	var body: some View {
		NavigationSplitView {
			List(items, id: \.self, selection: $selectedItem) { item in
				Text(item)
			}
		} detail: {
			if let selected = selectedItem {
				Text("Szczegóły: \(selected)")
					.frame(maxWidth: .infinity, maxHeight: .infinity)
			} else {
				Text("Wybierz wiadomość")
					.frame(maxWidth: .infinity, maxHeight: .infinity)
			}
		}
		.toolbar {
			ToolbarItemGroup(placement: .navigation) {
					// Ikony po lewej stronie
				Button(action: {}) {
					Label("New", systemImage: "plus")
				}

				Button(action: {}) {
					Label("Refresh", systemImage: "arrow.clockwise")
				}

				Button(action: {}) {
					Label("Reply", systemImage: "arrowshape.turn.up.left")
				}

				Button(action: {}) {
					Label("Forward", systemImage: "arrowshape.turn.up.right")
				}

				Button(action: {}) {
					Label("Trash", systemImage: "trash")
				}
			}
					// Spacer wypycha wyszukiwarkę na prawą stronę
			ToolbarItemGroup {
					// Wyszukiwanie
				HStack {
					Image(systemName: "magnifyingglass")
					TextField("Search", text: $searchText)
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.frame(width: 200)
					Button(action: {
							// Tu możesz dodać akcję filtrowania
					}) {
						Image(systemName: "line.3.horizontal.decrease.circle")
					}
					.buttonStyle(PlainButtonStyle())
				}
			}
		}
	}
}


#Preview {
	ContentView()
		.frame(width: 1000)
}
