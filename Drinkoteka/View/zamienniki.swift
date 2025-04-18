import SwiftData
import SwiftUI

struct zamienniki: View {
	@Environment(\.modelContext) private var modelContext
	
	@Query(sort: [SortDescriptor(\Drink_M.drNazwa)])
	private var wszystkieDrinki: [Drink_M]
	
	@State private var tekstFiltru: String = ""
	
	var przefiltrowaneDrinki: [Drink_M] {
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
							VStack{
								List {
									Text("Nazwa: \(drink.drNazwa)")
										.font(.headline)
									Text("Kat.: \(drink.drKat.rawValue)")
									Text("Żródło: \(drink.drZrodlo)")
									Text("Kolor: \(drink.drKolor)")
									Text("Foto: \(drink.drFoto)")
									Text("Proc.: \(drink.drProc)")
									Text("Słodycz: \(drink.drSlodycz.rawValue)")
									Text("Szkło: \(drink.drSzklo.opis)")
									Text("Ulubiony: \(drink.drUlubiony)")
									Text("Notatka: \(drink.drNotatka)")
									Text("Uwagi: \(drink.drUwagi)")
									Text("WWW: \(drink.drWWW)")
									Text("Kalorie: \(drink.drKalorie)")
									Text("Moc: \(drink.drMoc.opisLong)")
									Text("Brak: \(drink.drBrakuje)")
									if drink.drAlkGlowny.count == 1 {
										Text("Alk gł.: \(drink.drAlkGlowny[0].opis)")
									}
									if drink.drAlkGlowny.count == 2 {
										Text("Alk gł.: \(drink.drAlkGlowny[0].opis), \(drink.drAlkGlowny[1].opis)")
									}
									
								}
								Divider()
								List {
									ForEach(drink.drPrzepis.sorted { $0.przepNo < $1.przepNo }) { przep in
										HStack {
											Text("\(przep.przepNo)")
											Text("\(przep.przepOpis)")
											Spacer()
											Text("\(przep.przepOpcja)")
										}
									}
								}
								Divider()
								List {
									ForEach(drink.drSklad) { sklad in
										HStack {
											Text("\(sklad.sklNo)")
											Text("\(sklad.skladnikID)")
											Text("\(sklad.sklIlosc)")
											Text("\(sklad.sklMiara)")
											Text("\(sklad.sklInfo)")
											Spacer()
											Text("\(sklad.sklOpcja)")
										}
									}
								}
							}
						} label: {
							Text("\(drink.drNazwa)")
							Text("P: \(drink.drPrzepis.count)")
							Text("S: \(drink.drSklad.count)")
						}
					}
					.onDelete(perform: deleteDrink)
				}
			}
			.onAppear {
				if !UserDefaults.standard.bool(forKey: "zamiennikiWczytane") {
					UserDefaults.standard.set(true, forKey: "zamiennikiWczytane")
//				deleteAll(modelContext: modelContext)
				loadDrinkiCSV_V(modelContext: modelContext)
				loadDrinkiAlkGlownyCSV_V(modelContext: modelContext)
				loadDrinkiPrzepisyCSV_V(modelContext: modelContext)
				loadDrinkiSkladnikiCSV_V(modelContext: modelContext)
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
		let fetchDescriptor1 = FetchDescriptor<Drink_M>()
		do {
			let drinki = try modelContext.fetch(fetchDescriptor1)
			for drink in drinki {
				modelContext.delete(drink)
			}
			try modelContext.save()
		} catch {
			print("Błąd przy usuwaniu drinków: \(error)")
		}
//		
//		let fetchDescriptor2 = FetchDescriptor<DrinkSkladnik_M>()
//		do {
//			let skladniki = try modelContext.fetch(fetchDescriptor2)
//			for skladnik in skladniki {
//				modelContext.delete(skladnik)
//			}
//			try modelContext.save()
//		} catch {
//			print("Błąd przy usuwaniu drinków: \(error)")
//		}
//		
//		let fetchDescriptor3 = FetchDescriptor<DrinkPrzepis_M>()
//		do {
//			let przepisy = try modelContext.fetch(fetchDescriptor3)
//			for przepis in przepisy {
//				modelContext.delete(przepis)
//			}
//			try modelContext.save()
//		} catch {
//			print("Błąd przy usuwaniu drinków: \(error)")
//		}
	}
}




#Preview {
	
	NavigationStack {
		zamienniki()
	}
	.modelContainer(for: SklZamiennik.self, inMemory: true)
}
