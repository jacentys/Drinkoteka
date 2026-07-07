import SwiftData
import SwiftUI

struct DrinkiLista_V: View {
	@Environment(\.modelContext) private var modelContext
	@Query(sort: \Dr_M.drNazwa) private var drinki: [Dr_M]
	@Query private var skladniki: [Skl_M]
	@StateObject private var auth = AuthService_VM.shared

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
	@State var pokazDodajDrink: Bool = false
	@State private var noweDrinkiCount: Int = 0
	@State private var pokazAktualizacje: Bool = false

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
				// MARK: - POLE WYSZUKIWANIA
				SearchBar_V(searchText: $szukaj)
					.listRowBackground(Color.white.opacity(0.3))

				// MARK: - LISTA
				List {
					// MARK: - LICZNIK
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
						if auth.isRefreshing {
							ProgressView()
								.frame(maxWidth: .infinity)
								.listRowBackground(Color.clear)
						} else {
							switch sortowEnum {
							case .slodycz:
								SortSlodyczView()
							case .procenty:
								SortMocView()
							case .kcal:
								SortKcalView()
							case .sklad:
								SortSkladView()
							default:
								ForEach(filtrujDrinki().sorted {
									sortowRosn ? $0.drNazwa < $1.drNazwa : $0.drNazwa > $1.drNazwa
								}) { drink in
									DrinkListaWiersz_V(drink: drink, isLoggedIn: auth.isLoggedIn)
										.listRowBackground(Color.white.opacity(drink.czyIBA || auth.isLoggedIn ? 0.4 : 0.2))
								}
							}
						}
					}
				}
#if os(iOS)
				.listRowSpacing(2)
				.listStyle(.plain)
#endif
				.listRowSeparator(.hidden)
#if os(macOS)
				.listStyle(.automatic)
#endif
				.scrollContentBackground(.hidden)
			}
			.background(Back_V().ignoresSafeArea())
			
			.toolbar {
					// MARK: - TOOLBAR PRAWO
				if auth.isLoggedIn {
					ToolbarItem(placement: .navigationBarTrailing) {
						Button {
							pokazDodajDrink.toggle()
						} label: {
							Image(systemName: "plus.circle")
						}
						.sheet(isPresented: $pokazDodajDrink) {
							DrinkDodaj_V()
						}
					}
				}
				ToolbarItem(placement: .navigationBarTrailing) {
					Menu {
						Picker("Sortuj wg.", selection: $sortowEnum) {
							Label("Nazwa", systemImage: "textformat.abc").tag(sortEnum.nazwa)
							Label("Słodkość", systemImage: "drop.degreesign.fill").tag(sortEnum.slodycz)
							Label("Moc", systemImage: "bolt.fill").tag(sortEnum.procenty)
							Label("Kalorie", systemImage: "flame").tag(sortEnum.kcal)
							Label("Składniki", systemImage: "waterbottle").tag(sortEnum.sklad)
						}
						Divider()
						Button {
							sortowRosn.toggle()
						} label: {
							Label(sortowRosn ? "Malejąco" : "Rosnąco",
								  systemImage: sortowRosn ? "chevron.down" : "chevron.up")
						}
					} label: {
						Image(systemName: "arrow.up.arrow.down.circle")
					}
				}
				ToolbarItem(placement: .navigationBarTrailing) {
					Button {
						pokazFiltr.toggle()
					} label: {
						Image(systemName: "line.3.horizontal.decrease.circle")
					}
					.sheet(isPresented: $pokazFiltr) {
						DrinkFiltry_V()
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
			.task(id: auth.session?.user.id) {
				await loadNotesFromSupabase(modelContext: modelContext)
				await sprawdzAktualizacje()
			}
			.alert("Nowe drinki", isPresented: $pokazAktualizacje) {
				Button("Pobierz") { pobierzNoweDrinki() }
				Button("Później", role: .cancel) {}
			} message: {
				Text("Dostępnych jest \(noweDrinkiCount) nowych drinków. Pobrać teraz?")
			}
		}
	}

		// MARK: - SPRAWDŹ AKTUALIZACJE
	private func sprawdzAktualizacje() async {
		// Pomijamy przy pierwszym uruchomieniu — wtedy loadAllDrinks robi pełne ładowanie
		guard UserDefaults.standard.bool(forKey: "setupDone") else { return }
		if let count = await sprawdzAktualizacjeDrinkow(modelContext: modelContext), count > 0 {
			noweDrinkiCount = count
			pokazAktualizacje = true
		}
	}

		// MARK: - POBIERZ NOWE DRINKI
	private func pobierzNoweDrinki() {
		// Loader jest idempotentny — dodaje tylko nowe drinki,
		// nie kasuje stanu barku ani ulubionych
		Task {
			await loadFromSupabase(modelContext: modelContext)
			await loadNotesFromSupabase(modelContext: modelContext)
		}
	}
		// MARK: - LOAD ALL DRINKS
	private func loadAllDrinks() {
		guard !UserDefaults.standard.bool(forKey: "setupDone") else { return }
		delAll()
		Task {
			await loadFromSupabase(modelContext: modelContext)
			UserDefaults.standard.set(true, forKey: "setupDone")
		}
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
//		print("Funkcja delAll uruchomiona")
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
			
			let filtrPermisji = auth.canAccessDrink(drink)

			return filtrSlodkosci && filtrMocy && filtrAlkGlownego && filtrPreferencji && filtrPermisji
		}
	}
}
// MARK: - STARE WIDOKI SORTOWANIA (przeniesione do DrinkiListaSort_V.swift)
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

				let opis = slodycz.opis
				let przefiltrowane = drClass.filtrujDrinki(pref: pref)
					.filter { $0.drSlodycz == slodycz }
					.sorted { $0.id < $1.id }

				if !przefiltrowane.isEmpty {
					Section {
						HStack(alignment: .firstTextBaseline, spacing: 0) {
							Text(LocalizedStringKey(opis))
								.textCase(.uppercase)
								.font(.title2)
							Text(" \(przefiltrowane.count) ")
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
								Text(LocalizedStringKey(opis))
									.textCase(.uppercase)
									.font(.title2)
								Text(" \(przefiltrowane.count) ")
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
							Text(indeks == 0 ? "Masz wszystkie skł." : "Brak \(indeks) skł.")
								.textCase(.uppercase)
								.font(.title2)
							Text(" \(drinkiFiltrowane.count) ")
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



#Preview {
	NavigationStack {
		DrinkiLista_V()
	}
}
