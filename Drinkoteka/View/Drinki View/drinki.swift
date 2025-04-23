import SwiftData
import SwiftUI

struct drinki: View {
	@Environment(\.modelContext) private var modelContext

	@Query(sort: [SortDescriptor(\Dr_M.drNazwa)])
	private var drinki: [Dr_M]
	@State private var selectedDrink: Dr_M?

	@State private var tekstFiltru: String = ""

	var przefiltrowaneDrinki: [Dr_M] {
		if tekstFiltru.isEmpty {
			return drinki
		} else {
			return drinki.filter {
				$0.drNazwa.localizedCaseInsensitiveContains(tekstFiltru)
			}
		}
	}

	var body: some View {
		NavigationSplitView {
			TextField("Szukaj drinka...", text: $tekstFiltru)
				.textFieldStyle(.roundedBorder)
				.padding()
			List(drinki, selection: $selectedDrink) { drink in
				DrinkiListaRow_V(drink: drink)
			}
			.navigationTitle("Drinki")
		} detail: {
			if let selectedDrink = selectedDrink {
				Drink_V(drink: selectedDrink)
			} else {
				Text("Wybierz drinka z listy")
					.font(.title)
					.foregroundStyle(.secondary)
			}
		}
	}
}

/*			Text("\(przefiltrowaneDrinki.count)")
			VStack {
				TextField("Szukaj drinka...", text: $tekstFiltru)
					.textFieldStyle(.roundedBorder)
					.padding()
				List {
					ForEach(przefiltrowaneDrinki) { drink in
						NavigationLink {
							Drink_V(drink: drink)
						} label: {
							Text("\(drink.drNazwa)")
								.font(.headline)
						}
					}
					.onDelete(perform: delDrink)
				}
			}
			.onAppear {
				print("Początek onAppear drinków: \(UserDefaults.standard.bool(forKey: "setupDone"))")

				if UserDefaults.standard.bool(forKey: "setupDone")
				{
					delAll()
					loadDrCSV_V(modelContext: modelContext)
					loadDrAlkGlownyCSV_V(modelContext: modelContext)
					loadDrPrzepisyCSV_V(modelContext: modelContext)
					loadDrSkladnikiCSV_V(modelContext: modelContext)
					UserDefaults.standard.set(true, forKey: "setupDone")
				}
				print("Koniec onAppear drinków: \(UserDefaults.standard.bool(forKey: "setupDone"))")
			}
#if os(macOS)
			.navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
			.toolbar {
#if os(iOS)
				ToolbarItem(placement: .navigationBarTrailing) {
					EditButton()
				}
#endif

					// Przyciski macOS/iOS w osobnych ToolbarItemach
				ToolbarItem {
					Button(action: {
						delAll()
						loadDrCSV_V(modelContext: modelContext)
						loadDrAlkGlownyCSV_V(modelContext: modelContext)
						loadDrPrzepisyCSV_V(modelContext: modelContext)
						loadDrSkladnikiCSV_V(modelContext: modelContext)
					}) {
						Image(systemName: "restart.circle.fill")
					}
				}

				ToolbarItem {
					Button(action: addZam) {
						Label("Add Zamiennik", systemImage: "plus")
					}
				}

				ToolbarItem {
					Button("Filtry") {
//						openFiltryWindow()
					}
				}
			}

		} detail: {
			Text("Wybierz")
		}
	}

//	func openFiltryWindow() {
//		let window = NSWindow(
//			contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
//			styleMask: [.titled, .closable, .resizable],
//			backing: .buffered, defer: false
//		)
//		window.title = "Filtry drinków"
//		window.isReleasedWhenClosed = false
//		window.center()
//		window.contentView = NSHostingView(rootView: DrinkFiltry_V())
//		window.makeKeyAndOrderFront(nil)
//	}

	private func addZam() {
		print("Funkcja addZam uruchomiona")
//		withAnimation {
//			let zam = SklZamiennik(skladnikID: "SkładnikID", zamiennikID: "ID zamiennika")
//			modelContext.insert(zam)
//		}
	}
	
	private func delDrink(offsets: IndexSet) {
		withAnimation {
			for index in offsets {
				print("Funkcja delDrink \(przefiltrowaneDrinki[index].drNazwa) uruchomiona")
				modelContext.delete(przefiltrowaneDrinki[index])
			}
		}
	}
	
	func delAll() {
		print("Funkcja delAll uruchomiona")
		do {
			try modelContext.delete(model: Dr_M.self)
		} catch {
			print("Błąd przy usuwaniu drinków: \(error)")
		}
	}
}


*/

#Preview {
	
	NavigationStack {
		drinki()
	}
	.modelContainer(for: Dr_M.self, inMemory: true)
}
