import SwiftData
import SwiftUI

struct DrinkiLista_V: View {
	@Environment(\.modelContext) private var modelContext
	@Query(sort: \Dr_M.drNazwa) private var drinki: [Dr_M]
	@Query private var skladniki: [Skl_M]

//	var drinki2 = drMockArray()

	// MARK: - PREFERENCJE
	@AppStorage("zalogowany") var zalogowany: Bool = false
	@AppStorage("uzytkownik") var uzytkownik: String = ""
	@AppStorage("uzytkownikMail") var uzytkownikMail: String = ""
	
	@AppStorage("sortowEnum") var sortowEnum: sortEnum = .nazwa
	@AppStorage("sortowRosn") var sortowRosn: Bool = true
	
	@AppStorage("filtrAlkGlownyRum") var filtrAlkGlownyRum: Bool = true
	@AppStorage("filtrAlkGlownyWhiskey") var filtrAlkGlownyWhiskey: Bool = true
	@AppStorage("filtrAlkGlownyTequila") var filtrAlkGlownyTequila: Bool = true
	@AppStorage("filtrAlkGlownyBrandy") var filtrAlkGlownyBrandy: Bool = true
	@AppStorage("filtrAlkGlownyGin") var filtrAlkGlownyGin: Bool = true
	@AppStorage("filtrAlkGlownyVodka") var filtrAlkGlownyVodka: Bool = true
	@AppStorage("filtrAlkGlownyChampagne") var filtrAlkGlownyChampagne: Bool = true
	@AppStorage("filtrAlkGlownyInny") var filtrAlkGlownyInny: Bool = true
	
	@AppStorage("filtrSlodkoscNieSlodki") var filtrSlodkoscNieSlodki: Bool = true
	@AppStorage("filtrSlodkoscLekkoSlodki") var filtrSlodkoscLekkoSlodki: Bool = true
	@AppStorage("filtrSlodkoscSlodki") var filtrSlodkoscSlodki: Bool = true
	@AppStorage("filtrSlodkoscBardzoSlodki") var filtrSlodkoscBardzoSlodki: Bool = true
	
	@AppStorage("filtrMocBezalk") var filtrMocBezalk: Bool = true
	@AppStorage("filtrMocDelik") var filtrMocDelik: Bool = true
	@AppStorage("filtrMocSredni") var filtrMocSredni: Bool = true
	@AppStorage("filtrMocMocny") var filtrMocMocny: Bool = true
	
	@AppStorage("opcjonalneWymagane") var opcjonalneWymagane: Bool = false
	@AppStorage("zamiennikiDozwolone") var zamiennikiDozwolone: Bool = true
	@AppStorage("tylkoUlubione") var tylkoUlubione: Bool = false
	@AppStorage("tylkoDostepne") var tylkoDostepne: Bool = false

	@State var szukaj: String = ""
	@State var pokazFiltr: Bool = false

	var drinkiFiltered: [Dr_M] {
		if szukaj.isEmpty {
			return drinki
		} else {
			return drinki.filter {
				$0.drNazwa.localizedCaseInsensitiveContains(szukaj)
			}
		}
	}
	
	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				VStack {
						// MARK: - POLE WYSZUKIWANIA
					SearchBar_V(searchText: $szukaj)
				}
				.background(.regularMaterial)
					// MARK: - LISTA
				List {
					HStack(alignment: .firstTextBaseline, spacing: 0) {
						Text("\(filtrujDrinki().count) ")
							.font(.title2)
						Text("przep..")
							.font(.footnote)
						Spacer()
					}
					.fontWeight(.light)
					.foregroundColor(Color.primary)
					.listRowBackground(Color.white.opacity(0.7))
					.padding(.horizontal, 12)
						// MARK: - DRINKI
					if !drinki.isEmpty {
						ForEach(filtrujDrinki()) { drink in
							NavigationLink(
								destination: Drink_V(drink: drink),
								label: {
									DrinkListaRow(drink: drink)
										.listRowBackground(Color.white.opacity(0.4))
								})
							.buttonStyle(.plain)
						}
					}
				}
#if os(iOS)
				.listRowSpacing(2)
				.listStyle(.grouped)
#endif
				.listRowSeparator(.hidden)
#if os(macOS)
				.listStyle(.automatic)
#endif
				.scrollContentBackground(.hidden)
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
			.onAppear() {
				loadAllDrinks()
			}
		}
	}
		// MARK: - LOAD ALL DRINKS
	private func loadAllDrinks() {
		print("Startuje Load All, setupDone: \(UserDefaults.standard.bool(forKey: "setupDone"))")

		Task {
			do {
				let fetch = FetchDescriptor<Dr_M>()
				let wynik = try modelContext.fetch(fetch)
				print("Liczba drinków: \(wynik.count)")
			} catch {
				print("Błąd fetchowania: \(error)")
			}
		}

		
			//			debugPobrane(miejsce: "Ładowanie drinków")
		if !UserDefaults.standard.bool(forKey: "setupDone")
		{
			print("W pętli")
			delAll()
			loadSklCSV_V(modelContext: modelContext)
			loadDrCSV_V(modelContext: modelContext)
			loadDrSkladnikiCSV_V(modelContext: modelContext)
			loadDrAlkGlownyCSV_V(modelContext: modelContext)
			loadDrPrzepisyCSV_V(modelContext: modelContext)
			UserDefaults.standard.set(true, forKey: "setupDone")
			try? modelContext.save()
		}
		print("Koniec Load All, setupDone: \(UserDefaults.standard.bool(forKey: "setupDone"))")
			//			debugPobrane(miejsce: "Koniec Ładowania")
	}
		// MARK: - RESET ALL
	private func resetAll() {
		print("Startuje resetAll, setupDone: \(UserDefaults.standard.bool(forKey: "setupDone"))")


		Task {
			do {
				let fetch = FetchDescriptor<Dr_M>()
				let wynik = try modelContext.fetch(fetch)
				print("Liczba drinków: \(wynik.count)")
			} catch {
				print("Błąd fetchowania: \(error)")
			}
		}


		UserDefaults.standard.set(false, forKey: "setupDone")
		print("Zmiana wartości resetAll, setupDone: \(UserDefaults.standard.bool(forKey: "setupDone"))")
			//							debugPobrane(miejsce: "Przed")
		delAll()
		loadSklCSV_V(modelContext: modelContext)
		loadDrCSV_V(modelContext: modelContext)
		loadDrSkladnikiCSV_V(modelContext: modelContext)
		loadDrAlkGlownyCSV_V(modelContext: modelContext)
		loadDrPrzepisyCSV_V(modelContext: modelContext)
		try? modelContext.save()
			//							debugPobrane(miejsce: "Po")
		UserDefaults.standard.set(true, forKey: "setupDone")
		print("Koniec resetAll, setupDone: \(UserDefaults.standard.bool(forKey: "setupDone"))")
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
		// MARK: - FILTR
	func filtrujDrinki() -> [Dr_M] {
		
		return drinkiFiltered.filter { drink in
			
				// Filtrowanie po słodkości
			let filtrSlodkosci =
			(filtrSlodkoscNieSlodki && drink.drSlodycz == drSlodyczEnum.nieSlodki) ||
			(filtrSlodkoscLekkoSlodki && drink.drSlodycz == drSlodyczEnum.lekkoSlodki) ||
			(filtrSlodkoscSlodki && drink.drSlodycz == drSlodyczEnum.slodki) ||
			(filtrSlodkoscBardzoSlodki && drink.drSlodycz == drSlodyczEnum.bardzoSlodki) ||
			(drink.drSlodycz == drSlodyczEnum.brakDanych)
			
				// Filtrowanie po głównym alkoholu
			let filtrAlkGlownego =
			(filtrAlkGlownyRum && drink.drAlkGlowny.contains { $0 == .rum }) ||
			(filtrAlkGlownyWhiskey && drink.drAlkGlowny.contains { $0 == .whiskey }) ||
			(filtrAlkGlownyTequila && drink.drAlkGlowny.contains { $0 == .tequila }) ||
			(filtrAlkGlownyBrandy && drink.drAlkGlowny.contains { $0 == .brandy }) ||
			(filtrAlkGlownyGin && drink.drAlkGlowny.contains { $0 == .gin }) ||
			(filtrAlkGlownyVodka && drink.drAlkGlowny.contains { $0 == .vodka }) ||
			(filtrAlkGlownyChampagne && drink.drAlkGlowny.contains { $0 == .champagne }) ||
			(filtrAlkGlownyInny && drink.drAlkGlowny.contains { $0 == .inny })
			
				// Filtrowanie po mocy alkoholu
			let filtrMocy =
			((filtrMocBezalk && drink.drMoc == drMocEnum.bezalk) ||
			 (filtrMocDelik && drink.drMoc == drMocEnum.delik) ||
			 (filtrMocSredni && drink.drMoc == drMocEnum.sredni) ||
			 (filtrMocMocny && drink.drMoc == drMocEnum.mocny)) ||
			drink.drMoc == drMocEnum.brakDanych
			
				// Filtrowanie po preferencjach
			let filtrPreferencji =
			(!tylkoUlubione || drink.drUlubiony) &&
			(!tylkoDostepne || drink.drBrakuje == 0)
			
				//			return filtrSlodkosci && filtrMocy && filtrAlkGlownego && filtrPreferencji
			return filtrSlodkosci && filtrMocy && filtrAlkGlownego && filtrPreferencji
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

private func DrinkListaRow(drink: Dr_M) -> some View {
	HStack {
			// MARK: - IKONKA
		ZStack {
			Circle()
				.fill(.regularMaterial)
				.stroke(drink.getKolor(), lineWidth: drink.drBrakuje == 0 ? 2 : 1)
			
			Image(!drink.drFoto.isEmpty ? drink.drFoto :  drink.drSzklo.foto)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: 35, height: 35)
				.foregroundStyle(Color.primary)
			
			Image(systemName: "checkmark")
				.font(.system(size: 12))
				.fontWeight(.black)
				.frame(width: 60, height: 50, alignment: .bottomTrailing)
				.foregroundStyle(Color.primary.opacity(drink.drBrakuje == 0 ? 1 : 0))
		}
		.frame(width: 50, height: 50)
		Divider().frame(height: 50)
			// MARK: - OPIS
		VStack(spacing: 0) {
			VStack(alignment: .leading) {
				Text("\(drink.drNazwa)")
					.font(.headline)
					.foregroundStyle(Color.primary)
				Divider()
				Text("\(drink.drMoc)")
					.foregroundColor(Color.secondary)
					.font(.footnote)
			}
		}
		.frame(maxWidth: .infinity)
		Divider().frame(height: 50)
			// MARK: - SKALA
		DrinkSkala_V(drink: drink, wielkosc: 20, etykieta: false)
			.shadow(color: .white, radius: 20)
			.shadow(color: .white, radius: 20)
			.padding(.leading, 8)
			// MARK: - GWIAZDKA
		Image(systemName: drink.drUlubiony ? "star.fill" : "star")
			.font(.system(size: 23))
			.foregroundStyle(drink.drUlubiony ? Color.accent : Color.gray)
			//						.onTapGesture {
			//							drinkiClass.updateDrinkUlubiony(drink: drink)
			//						}
	}
}


#Preview {
	NavigationStack {
		DrinkiLista_V()
	}
}
