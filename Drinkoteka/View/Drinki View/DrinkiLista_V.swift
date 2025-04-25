import SwiftData
import SwiftUI

struct DrinkiLista_V: View {
	@Environment(\.modelContext) private var modelContext
//	@Query private var drinki: [Dr_M]
	@Query private var skladniki: [Skl_M]

	var drinki = drMockArray()

	@AppStorage("sortowEnum") var sortowEnum: sortEnum?
	@AppStorage("sortowRosn") var sortowRosn: Bool = true
	
	@AppStorage("opcjonalneWymagane") var opcjonalneWymagane: Bool = false
	@AppStorage("zamiennikiDozwolone") var zamiennikiDozwolone: Bool = false
	@AppStorage("tylkoUlubione") var tylkoUlubione: Bool = false
	@AppStorage("tylkoDostepne") var tylkoDostepne: Bool = false

	@State var szukaj: String = ""
	@State var pokazFiltr: Bool = false

	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				VStack {
					TextField("Szukaj...", text: $szukaj)
						.font(.headline)
				}
				.padding(.horizontal, 16)
				.padding(.vertical, 12)
				.background(.regularMaterial)

				VStack {
					List {
						Section("Test sekcji") {

							HStack(alignment: .firstTextBaseline, spacing: 0) {
								Text("\(drinki.count) ")
									.font(.title2)
								Text("przep..")
									.font(.footnote)
								Spacer()
							}
							.fontWeight(.light)
							.foregroundColor(Color.primary)
//							.listRowBackground(background(.regularMaterial))

						if !drinki.isEmpty {
							ForEach(drinki) { drink in
									rowek(drink: drink)
									.listRowBackground(Color.clear)

								}
						}
						}
//						.padding(.bottom, 30)
					}
					.listStyle(.plain)
					.scrollContentBackground(.hidden)
				}
			}
			.background(Back_V().ignoresSafeArea())

			.toolbar {
					// MARK: - TOOLBAR LEWO
				ToolbarItemGroup(placement: .navigation) {
					HStack(spacing: 0) {
							// Przycisk dostępnych
						Button {
							tylkoDostepne.toggle()
						} label: {
							Image(systemName: tylkoDostepne ? "checkmark.circle.fill" : "checkmark.circle")
								.foregroundStyle(tylkoDostepne ? Color.accent : Color.secondary)
						}

							// Przycisk ulubionych
						Button {
							tylkoUlubione.toggle()
						} label: {
							Image(systemName: tylkoUlubione ? "star.circle.fill" : "star.circle")
								.foregroundStyle(tylkoUlubione ? Color.accent : Color.secondary)
						}

							// Przycisk opcjonalne
						Button {
							opcjonalneWymagane.toggle()
						} label: {
							Image(systemName: opcjonalneWymagane ? "list.bullet.circle.fill" : "list.bullet.circle")
								.foregroundStyle(opcjonalneWymagane ? Color.accent : Color.secondary)
						}

							// Przycisk zamienników
						Button {
							zamiennikiDozwolone.toggle()
						} label: {
							Image(systemName: zamiennikiDozwolone ? "repeat.circle.fill" : "repeat.circle")
								.font(.headline)
								.foregroundStyle(zamiennikiDozwolone ? Color.accent : Color.secondary)
						}
					}
				}

					// MARK: - TOOLBAR PRAWO
				ToolbarItemGroup(placement: .destructiveAction) {
					HStack(spacing: 0) {
						Button {
							resetAll()
						} label: {
							Label("Reset", systemImage: "arrow.counterclockwise")
						}

						Button { /// Przycisk preferencji
							pokazFiltr.toggle()
						} label: {
							Image(systemName: "line.3.horizontal.decrease.circle")
								.font(.headline)
						}
						.sheet(isPresented: $pokazFiltr) {
							DrinkFiltry_V()
						}
					}
				}
			}
			.toolbarBackgroundVisibility(.visible)
			.toolbarBackground(Material.thinMaterial)
			.navigationViewStyle(.automatic)
			.navigationTitle("Drinki")

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
//			for index in offsets {
//				print("Funkcja delDrink \(przefiltrowaneDrinki[index].drNazwa) uruchomiona")
//				modelContext.delete(przefiltrowaneDrinki[index])
//			}
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
 	// MARK: - NAZWA LUB KALORIE
/*
struct SortNazwaView: View {
	var body: some View {

		if drinki.count == 0 {
				// Jeśli macierz jest pusta, wyświetlamy EmptyView lub inny widok
			return AnyView( EmptyView() )
		}

		return AnyView( // Jeśli macierz nie jest pusta, wyświetlamy dane w ScrollView
			ScrollView {
				Section {
					HStack(alignment: .firstTextBaseline, spacing: 0) {
						Text("\(drinki.count) ")
							.font(.title2)
						Text("przep..")
							.font(.footnote)
						Spacer()
					}
					.fontWeight(.light)
					.foregroundColor(Color.white)
					.offset(y: 14)
					.padding(.horizontal, 28)

					VStack(spacing: 2) {
						ForEach(drinki) { drink in
							DrinkiListaRow_V(drink: drink)
						}
					}
				}
				.padding(.bottom, 30)
			}
		)
	}
}

	// MARK: - SORT SŁODYCZ
struct SortSlodyczView: View {
	var body: some View {
		ScrollView {

				// Posortowanie enumów
			let enumSorted = drSlodyczEnum.allCases.sorted {
				sortowRosn ? $0.sort < $1.sort : $0.sort > $1.sort
			}

			ForEach(enumSorted, id: \.sort) { slodycz in

				let opis = slodycz.rawValue
				let przefiltrowane = drClass.filtrujDrinki(pref: pref)
					.filter { $0.drSlodycz == slodycz }
					.sorted { $0.id < $1.id }

				if !przefiltrowane.isEmpty {
					Section {
						HStack(alignment: .firstTextBaseline, spacing: 0) {
							Text("\(opis) \(przefiltrowane.count) ".uppercased())
								.font(.title2)
							Text("przep.")
								.font(.footnote)
							Spacer()
						}
						.fontWeight(.light)
						.foregroundColor(Color.white)
						.offset(y: 14)
						.padding(.horizontal, 28)
						VStack(spacing: 2) {
							ForEach(przefiltrowane, id: \.id) { drink in
								DrinkiListaRow_V(drink: drink)
							}
						}
					}
				}
			}
			.padding(.top, 12)
			.padding(.bottom, 30)
		}
	}
}

	// MARK: - SORT MOC
struct SortMocView: View {
	var body: some View {
		ScrollView {

				// Posortowanie enumów
			let enumSorted = drMocEnum.allCases.sorted {
				sortowRosn ? $0.sort < $1.sort : $0.sort > $1.sort
			}
			ForEach(enumSorted, id: \.rawValue) { moc in
					let opis = moc.opisLong
					let przefiltrowane = drClass.filtrujDrinki(pref: pref)
					.filter { $0.drMoc == moc }
					.sorted {
						if sortowRosn {
							return $0.drProc < $1.drProc  // Sortowanie według nazwy (rosnąco)
						} else {
							return $0.drProc > $1.drProc  // Sortowanie według nazwy (malejąco)
						}
					}

					if !przefiltrowane.isEmpty {
						Section {
							HStack(alignment: .firstTextBaseline, spacing: 0) {
								Text("\(opis) \(przefiltrowane.count) ".uppercased())
									.font(.title2)
								Text("przep.")
									.font(.footnote)
								Spacer()
							}
							.fontWeight(.light)
							.foregroundColor(Color.white)
							.offset(y: 14)
							.padding(.horizontal, 28)

							VStack(spacing: 2) {
								ForEach(przefiltrowane, id: \.id) { drink in
									DrinkiListaRow_V(drink: drink)
								}
							}
						}
					}
			}
			.padding(.top, 12)
			.padding(.bottom, 30)
		}
	}
}

	// MARK: - SORT SKLAD
struct SortSkladView: View {
	var body: some View {
		ScrollView {

			let zakres = drClass.brakMin...drClass.brakMax

			ForEach((zakres), id: \.self) { idx in
				let indeks = sortowRosn ? idx : drClass.brakMax - idx

					// Filtruj drinki wg ilości brakujących składników
				let drinkiFiltrowane = drClass.filtrujDrinki(pref: pref)
					.filter { $0.drBrakuje == indeks }
					.sorted { $0.drNazwa < $1.drNazwa }

				if !drinkiFiltrowane.isEmpty {
					Section {
						HStack(alignment: .firstTextBaseline, spacing: 0) {
							Text(indeks == 0 ? "Masz wszystkie skł. \(drinkiFiltrowane.count) ".uppercased() : "Brak \(indeks) skł. \(drinkiFiltrowane.count) ".uppercased())
								.font(.title2)
							Text("przep.")
								.font(.footnote)
							Spacer()
						}
						.fontWeight(.light)
						.foregroundColor(Color.white)
						.offset(y: 14)
						.padding(.horizontal, 28)

						VStack(spacing: 2) {
							ForEach(drinkiFiltrowane) { drink in
								DrinkiListaRow_V(drink: drink)
							}
						}
					}
				}
			}
			.padding(.top, 12)
			.padding(.bottom, 30)
		}
	}
}
*/

private func rowek2(drink: Dr_M) -> some View {
	Text("Test")
}

private func rowek(drink: Dr_M) -> some View {
		ZStack {
			Rectangle()
				.frame(minHeight: 66, maxHeight: 100)
				.frame(maxWidth: .infinity)
				.foregroundStyle(.thinMaterial)

//			HStack {
//				ZStack {
//					Circle()
//						.fill(.regularMaterial.opacity(drink.drBrakuje == 0 ? 0.8 : 0.8))
//						.stroke(drink.getKolor().opacity(drink.drBrakuje == 0 ? 0.8 : 0.8), lineWidth: drink.drBrakuje == 0 ? 1 : 1)
//
//					Image(!drink.drFoto.isEmpty ? drink.drFoto :  drink.drSzklo.foto)
//						.resizable()
//						.aspectRatio(contentMode: .fit)
//						.frame(width: 35, height: 35)
//						.foregroundStyle(Color.primary)
//
//					Image(systemName: "checkmark")
//						.font(.system(size: 12))
//						.fontWeight(.black)
//						.frame(width: 60, height: 50, alignment: .bottomTrailing)
//						.foregroundStyle(Color.primary.opacity(drink.drBrakuje == 0 ? 1 : 0))
//				}
//				.frame(width: 60, height: 50)
//
//				Divider()
//
//				VStack {
//					Spacer()
//
//					HStack(spacing: 0) {
//						VStack(alignment: .leading) {
//							Text("\(drink.drNazwa)")
//								.font(.headline)
//								.foregroundStyle(Color.primary)
//							Text("\(drink.drMoc)")
//								.foregroundColor(Color.secondary)
//								.font(.footnote)
//						}
//						Spacer()
//					}
//					Spacer()
//				}
//				.frame(width: 180)
//				Spacer()
//
//				VStack {
//					DrinkSkala_V(drink: drink, wielkosc: 20, etykieta: false)
//				}
//
//				Image(systemName: drink.drUlubiony ? "star.fill" : "star")
//					.font(.system(size: 23))
//					.foregroundStyle(drink.drUlubiony ? Color.accent : Color.gray)
//					//						.onTapGesture {
//					//							drinkiClass.updateDrinkUlubiony(drink: drink)
//					//						}
//			}
		}
}


#Preview {
	NavigationStack {
		DrinkiLista_V()
	}
}
