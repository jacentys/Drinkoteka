import SwiftData
import SwiftUI

struct drinki: View {
	@Environment(\.modelContext) private var modelContext

	@AppStorage("opcjonalneWymagane") var opcjonalneWymagane: Bool = false
	@AppStorage("zamiennikiDozwolone") var zamiennikiDozwolone: Bool = false
	@AppStorage("tylkoUlubione") var tylkoUlubione: Bool = false
	@AppStorage("tylkoDostepne") var tylkoDostepne: Bool = false

	@Query(sort: [SortDescriptor(\Dr_M.drNazwa)])
	private var drinki: [Dr_M]
	@State private var selectedDrink: Dr_M?
	@State private var tekstFiltru: String = ""
	@State private var pokazFiltr: Bool = false

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
		VStack {
			NavigationSplitView {
				// MARK: - LISTA DRINKÓW
				List(przefiltrowaneDrinki, selection: $selectedDrink) { drink in
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
			// MARK: - WYŁĄCZONE WYŚWIETLANIE ILOŚCI DRINKÓW
//			.safeAreaInset(edge: .bottom, content: {
//				Text("Ilość przepisów: \(przefiltrowaneDrinki.count)")
//					.padding(12)
//			})

			.toolbar {
				// MARK: - TOOLBAR PO LEWEJ
				ToolbarItemGroup(placement: .navigation) {
					Button{

					} label: {
						Label("New", systemImage: "plus")
					}

					Button{
						tylkoDostepne.toggle()
					} label: {
						Label("Pokaż tylko z posiadanych składników", systemImage: tylkoDostepne ? "checkmark.circle.fill" : "checkmark.circle")
							.foregroundStyle(tylkoDostepne ? Color.accent : Color.secondary)
					}

					Button {
						tylkoUlubione.toggle()
					} label: {
						Label("Pokaż tylko ulubione", systemImage: tylkoUlubione ? "star.circle.fill" : "star.circle")
							.foregroundStyle(tylkoUlubione ? Color.accent : Color.secondary)
					}

					Button {
						opcjonalneWymagane.toggle()
					} label: {
						Label("Wymagaj opcjonalnych składników", systemImage: opcjonalneWymagane ? "list.bullet.circle.fill" : "list.bullet.circle")
							.foregroundStyle(opcjonalneWymagane ? Color.accent : Color.secondary)
					}

					Button {
						zamiennikiDozwolone.toggle()
					} label: {
						Label("Wymagaj opcjonalnych składników", systemImage: zamiennikiDozwolone ?  "repeat.circle.fill" : "repeat.circle")
							.foregroundStyle(zamiennikiDozwolone ? Color.accent : Color.secondary)
					}
				}
					// MARK: - TOOLBAR PO PRAWEJ
				ToolbarItemGroup(placement: .destructiveAction) {
						// Wyszukiwanie
					HStack {
						Image(systemName: "magnifyingglass")
						TextField("Search", text: $tekstFiltru)
							.textFieldStyle(RoundedBorderTextFieldStyle())
							.frame(width: 200)

						Button {
							pokazFiltr.toggle()
						} label: {
							Image(systemName: "line.3.horizontal.decrease.circle")
						}

						Button {
							resetAll()
						} label: {
							Label("Reset", systemImage: "arrow.counterclockwise")
						}
						.sheet(isPresented: $pokazFiltr) {
							DrinkFiltry_V()
						}
					}
				}
			}
		}
		.onAppear {
			loadAllDrinks()
		}

	}
	// MARK: - LOAD ALL DRINKS

	private func loadAllDrinks() {
			//			debugPobrane(miejsce: "Ładowanie drinków")
		if !UserDefaults.standard.bool(forKey: "setupDone")
		{
			delAll()
			loadSklCSV_V(modelContext: modelContext)
			loadDrCSV_V(modelContext: modelContext)
			loadDrSkladnikiCSV_V(modelContext: modelContext)
			loadDrAlkGlownyCSV_V(modelContext: modelContext)
			loadDrPrzepisyCSV_V(modelContext: modelContext)
			UserDefaults.standard.set(true, forKey: "setupDone")
		}
			//			debugPobrane(miejsce: "Koniec Ładowania")
	}
	// MARK: - RESET ALL

	private func resetAll() {
		UserDefaults.standard.set(false, forKey: "setupDone")
			//							debugPobrane(miejsce: "Przed")
		delAll()
		loadSklCSV_V(modelContext: modelContext)
		loadDrCSV_V(modelContext: modelContext)
		loadDrSkladnikiCSV_V(modelContext: modelContext)
		loadDrAlkGlownyCSV_V(modelContext: modelContext)
		loadDrPrzepisyCSV_V(modelContext: modelContext)
			//							debugPobrane(miejsce: "Po")
		UserDefaults.standard.set(true, forKey: "setupDone")
	}
	// MARK: - ADD DRINK

	private func addDrink() {
		print("Funkcja addDrink uruchomiona")
			//		withAnimation {
			//			let zam = SklZamiennik(skladnikID: "SkładnikID", zamiennikID: "ID zamiennika")
			//			modelContext.insert(zam)
			//		}
	}
	// MARK: - DEL DRINK

	private func delDrink(offsets: IndexSet) {
		withAnimation {
			for index in offsets {
				print("Funkcja delDrink \(przefiltrowaneDrinki[index].drNazwa) uruchomiona")
				modelContext.delete(przefiltrowaneDrinki[index])
			}
		}
	}
	// MARK: - DEL ALL

	private func delAll() {
		print("Funkcja delAll uruchomiona")
		do {
			try modelContext.delete(model: Skl_M.self)
			try modelContext.delete(model: Dr_M.self)
		} catch {
			print("Błąd przy usuwaniu drinków: \(error)")
		}
	}

	// MARK: - DEBUG POBRANE

	private func debugPobrane(miejsce: String) {
		do {
			let fetchRequestDR = FetchDescriptor<Dr_M>()
			let fetchRequestSKL = FetchDescriptor<Skl_M>()

			let allDrinks = try modelContext.fetch(fetchRequestDR)
			let allSkladniki = try modelContext.fetch(fetchRequestSKL
			)
			print("W miejscu \(miejsce) \(allDrinks.count) drinków i \(allSkladniki.count) składników")
		} catch {
			print("Błąd przy pobieraniu drinków: \(error)")
		}
	}
}


#Preview {
	NavigationStack {
		drinki()
			.frame(width: 900)
	}
	.modelContainer(for: Dr_M.self, inMemory: true)
}
