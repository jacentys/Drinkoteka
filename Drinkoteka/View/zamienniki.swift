import SwiftData
import SwiftUI

struct zamienniki: View {
	@Environment(\.modelContext) private var modelContext
	
	@Query(sort: [SortDescriptor(\Drink.drNazwa)])
	private var wszystkieDrinki: [Drink]
	
	@State private var tekstFiltru: String = ""
	
	var przefiltrowaneDrinki: [Drink] {
		if tekstFiltru.isEmpty {
			return wszystkieDrinki
		} else {
			return wszystkieDrinki.filter {
				$0.drNazwa.localizedCaseInsensitiveContains(tekstFiltru)
			}
		}
	}
	
	var body: some View {
		NavigationSplitView {
			Text("\(przefiltrowaneDrinki.count)")
			VStack {
				TextField("Szukaj drinka...", text: $tekstFiltru)
					.textFieldStyle(.roundedBorder)
					.padding()
				List {
					ForEach(przefiltrowaneDrinki) { drink in
						NavigationLink {
							Text("\(drink.drNazwa)")
						} label: {
							Text(drink.drNazwa)
						}
					}
					.onDelete(perform: deleteDrink)
				}
			}
			.onAppear {
				if !UserDefaults.standard.bool(forKey: "zamiennikiWczytane") {
					UserDefaults.standard.set(true, forKey: "zamiennikiWczytane")
					deleteAll(modelContext: modelContext)
					loadZamCSV(modelContext: modelContext)
					loadDrinkiCSV(modelContext: modelContext)
				}
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
				ToolbarItem {
					Button(action: addZam) {
						Label("Add Zamiennik", systemImage: "plus")
					}
				}
			}
		} detail: {
			Text("Wybierz")
		}
	}
	
	private func addZam() {
		withAnimation {
			let zam = SklZamiennik(skladnikID: "SkładnikID", zamiennikID: "ID zamiennika")
			modelContext.insert(zam)
		}
	}
	
	private func deleteDrink(offsets: IndexSet) {
		withAnimation {
			for index in offsets {
				modelContext.delete(przefiltrowaneDrinki[index])
			}
		}
	}
	
	func deleteAll(modelContext: ModelContext) {
		let fetchDescriptor = FetchDescriptor<Drink>()
		
		do {
			let drinki = try modelContext.fetch(fetchDescriptor)
			for drink in drinki {
				modelContext.delete(drink)
			}
			try modelContext.save()
		} catch {
			print("Błąd przy usuwaniu drinków: \(error)")
		}
	}
}




#Preview {
	
	NavigationStack {
		zamienniki()
	}
	.modelContainer(for: SklZamiennik.self, inMemory: true)
}
