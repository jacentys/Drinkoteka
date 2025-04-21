import SwiftData
import SwiftUI

struct drinki: View {
	@Environment(\.modelContext) private var modelContext
	
	@Query(sort: [SortDescriptor(\Dr_M.drNazwa)])
	private var wszystkieDrinki: [Dr_M]
	
	@State private var tekstFiltru: String = ""
	
	var przefiltrowaneDrinki: [Dr_M] {
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
									Text("Kalorie: \(drink.drKal)")
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
								DrinkPrzepisView(drSelID: drink.drinkID)
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
					.onDelete(perform: delDrink)
				}
			}
			.onAppear {
				print("Początek onAppear: \(UserDefaults.standard.bool(forKey: "setupDone"))")
				
				if !UserDefaults.standard.bool(forKey: "setupDone")
				{
					delAll()
					loadDrCSV_V(modelContext: modelContext)
					loadDrAlkGlownyCSV_V(modelContext: modelContext)
					loadDrPrzepisyCSV_V(modelContext: modelContext)
					loadDrSkladnikiCSV_V(modelContext: modelContext)
					UserDefaults.standard.set(true, forKey: "setupDone")
				}
				print("Koniec onAppear: \(UserDefaults.standard.bool(forKey: "setupDone"))")
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
					Button(action: {
						delAll()
						loadDrCSV_V(modelContext: modelContext)
						loadDrAlkGlownyCSV_V(modelContext: modelContext)
						loadDrPrzepisyCSV_V(modelContext: modelContext)
						loadDrSkladnikiCSV_V(modelContext: modelContext)
					}) { Image(systemName: "restart.circle.fill") }
					
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




#Preview {
	
	NavigationStack {
		drinki()
	}
	.modelContainer(for: Dr_M.self, inMemory: true)
}
