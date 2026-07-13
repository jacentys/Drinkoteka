// Lista drinków: wyszukiwanie, sortowanie, filtry, pierwsze ładowanie danych,
// sprawdzanie aktualizacji i alert o nowych drinkach.
import SwiftData
import SwiftUI

struct DrinkiLista_V: View {
	@Environment(\.modelContext) private var modelContext
	@Query(sort: \Dr_M.drNazwa) private var drinki: [Dr_M]
	@Query private var skladniki: [Skl_M]
	@StateObject private var auth = AuthService_VM.shared


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
	@State private var pokazPremiumDodaj: Bool = false
	@State private var noweDrinkiCount: Int = 0
	@State private var pokazAktualizacje: Bool = false
	@State private var toastMessage: String? = nil

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
									DrinkListaWiersz_V(drink: drink, mozeOtworzyc: auth.mozeOtworzyc(drink))
										.listRowBackground(Color.white.opacity(auth.mozeOtworzyc(drink) ? 0.4 : 0.2))
										.swipeActions(edge: .trailing, allowsFullSwipe: true) {
											// Własny drink: usuwalny lokalnie przez każdego.
											// Drink katalogowy/serwerowy: usuwalny tylko przez admina (kasuje też z serwera).
											if drink.drZrodlo == "Własny" || auth.isAdmin {
												Button(role: .destructive) {
													usunDrink(drink)
												} label: {
													Label("Usuń", systemImage: "trash")
												}
											}
										}
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
			.toast(message: $toastMessage)

			.toolbar {
					// MARK: - TYTUŁ (jak "Drinkotheque" na ekranie głównym)
				ToolbarItem(placement: .principal) {
					Text("Drinki")
						.font(.largeTitle)
						.fontWeight(.light)
						.foregroundStyle(Color.primary)
						.shadow(color: .black.opacity(0.6), radius: 6)
				}

					// MARK: - TOOLBAR LEWO: ulubione
				ToolbarItem(placement: .navigationBarLeading) {
					Button {
						tylkoUlubione.toggle()
						toastMessage = tylkoUlubione ? "Pokazuję tylko ulubione" : "Pokazuję wszystkie"
					} label: {
						Image(systemName: tylkoUlubione ? "star.fill" : "star")
							.foregroundStyle(tylkoUlubione ? Color.accent : Color.secondary)
					}
					.accessibilityLabel(tylkoUlubione ? "Pokaż wszystkie" : "Tylko ulubione")
				}

					// MARK: - TOOLBAR PRAWO
				if auth.isLoggedIn {
					ToolbarItem(placement: .navigationBarTrailing) {
						Button {
							// Dodawanie własnych drinków: Premium lub admin
							if auth.mozeTworzyc {
								pokazDodajDrink = true
							} else {
								pokazPremiumDodaj = true
							}
						} label: {
							Image(systemName: "plus.circle")
						}
						.sheet(isPresented: $pokazDodajDrink) {
							DrinkDodaj_V()
						}
						.sheet(isPresented: $pokazPremiumDodaj) {
							PremiumInfo_V(opis: "Dodawanie własnych drinków — ze zdjęciem, składnikami i przepisem — jest dostępne w planie Premium.")
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
			.toolbarBackground(.visible, for: .navigationBar)
			.toolbarBackground(Material.thinMaterial, for: .navigationBar)
			.navigationViewStyle(.automatic)
			.navigationBarTitleDisplayMode(.inline)
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
		// Pomijamy do czasu pierwszego pełnego załadowania (robi je CustomTab_V w korzeniu)
		guard UserDefaults.standard.bool(forKey: "setupDone") else { return }
		if let count = await sprawdzAktualizacjeDrinkow(modelContext: modelContext), count > 0 {
			noweDrinkiCount = count
			pokazAktualizacje = true
		}
	}

		// MARK: - USUŃ DRINK
	private func usunDrink(_ drink: Dr_M) {
		let byłNaSerwerze = drink.drZrodlo != "Własny"
		let drinkID = drink.drinkID
		modelContext.delete(drink)
		try? modelContext.save()
		if byłNaSerwerze {
			Task { await usunDrinkZServera(drinkId: drinkID) }
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
		// MARK: - DEBUG POBRANE
	private func debugPobrane(miejsce: String) {
		do {
			let fetchRequestDR = FetchDescriptor<Dr_M>()
			let fetchRequestSKL = FetchDescriptor<Skl_M>()

			let allDrinks = try modelContext.fetch(fetchRequestDR)
			let allSkladniki = try modelContext.fetch(fetchRequestSKL
			)
			dprint("W miejscu \(miejsce) \(allDrinks.count) drinków i \(allSkladniki.count) składników")
		} catch {
			dprint("Błąd przy pobieraniu drinków: \(error)")
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



#Preview {
	NavigationStack {
		DrinkiLista_V()
	}
}
