// Ekran startowy: kafelki wg głównego alkoholu (przełączają zakładkę na Drinki z filtrem)
// oraz sekcja polecanych drinków.
import SwiftData
import SwiftUI

struct Home_V: View {
	@Binding var activeTab: Tab
	@Environment(\.modelContext) private var modelContext
	@Query(sort: \Dr_M.drNazwa)
	private var wszystkieDrinki: [Dr_M]
	@Query(
		filter: #Predicate<Dr_M> { $0.drUlubiony == true },
		sort: \Dr_M.drNazwa
	)
	private var ulubione: [Dr_M]

	@AppStorage("jezykAplikacji") var jezykAplikacji: String = "pl"

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
	
	@StateObject private var auth = AuthService_VM.shared
	@State private var pokazPremium: Bool = false
	let columns: [GridItem] = [GridItem(.adaptive(minimum: 100, maximum: 200), spacing: 12, alignment: nil)]

	// Recommended: zawsze 2 rzędy — stała liczba kolumn (nie adaptacyjna jak reszta siatek)
	private let polecaneKolumny = 3
	private var recommendedColumns: [GridItem] {
		Array(repeating: GridItem(.flexible(), spacing: 10), count: polecaneKolumny)
	}

		// Losowanie drinków "Polecane" — stabilne przez cały dzień (ten sam seed = ta sama lista),
		// zmienia się automatycznie następnego dnia. Zastępuje ręczne oznaczanie `drPolecany`.
	private var polecaneDzisiaj: [Dr_M] {
		let dostepne = wszystkieDrinki.filter { auth.canAccessDrink($0) }
		guard !dostepne.isEmpty else { return [] }
		let dzien = dzisiejszaDataString()
		return dostepne
			.sorted { stabilnyHash("\($0.drinkID)|\(dzien)") < stabilnyHash("\($1.drinkID)|\(dzien)") }
			.prefix(polecaneKolumny * 2)
			.map { $0 }
	}

	var body: some View {
		NavigationView {
			ScrollView {
				VStack(alignment: .leading, spacing: 16) {
					Section {
						ScrollView(.horizontal) {
							LazyHStack(alignment: .top, spacing: 12) {
								ForEach(alkGlownyEnum.allCases, id: \.self) { kategoria in

										// - MARK: KAFELEK
									ZStack {
										Rectangle()
											.foregroundStyle(.ultraThinMaterial)

										ZStack {
											VStack {
												Spacer()
												Rectangle()
													.foregroundStyle(.thinMaterial)
													.frame(height: 30)
											}
										}

										Image(kategoria.foto)
											.resizable()
											.aspectRatio(contentMode: .fit)
											.padding(24)
											.offset(x: 0, y: -12)

										VStack {
											Spacer()
											Text(kategoria.opisPL.uppercased())
												.font(.caption)
												.fontWeight(.semibold)
												.foregroundStyle(.primary)
												.shadow(color: .gray, radius: 10)
												.shadow(color: .gray, radius: 5)
												.padding(.bottom, 6)
										}

										Button {
											wyborAlko(wybor: kategoria)
											activeTab = .drinki
										} label: {
											Rectangle()
												.fill(Color.clear)
										}
									}
									.aspectRatio(1, contentMode: .fit)
									.mask(RoundedRectangle(cornerRadius: 6))
									.overlay(RoundedRectangle(cornerRadius: 6).stroke(.white, lineWidth: 1))
									.scrollTransition(.interactive, axis: .horizontal) { content, phase in
										content
											.scaleEffect(phase.isIdentity ? 1 : 0.82)
											.opacity(phase.isIdentity ? 1 : 0.7)
									}
								} /// KONIEC FOREACH
								.scrollTargetLayout()
							} /// KONIEC LAZYVSTACK
						} /// KONIEC VSCROLL
						.scrollTargetBehavior(.viewAligned)
						.scrollContentBackground(.hidden)
						.frame(height: 150)
					} header: {
						HStack {
							Text("Według alkoholu").textCase(.uppercase)
								.font(.title2)
								.fontWeight(.light)
								.foregroundStyle(Color.primary)
							Spacer()
						}
						.padding(.top, 20)
					}

					// MARK: - ULUBIONE
					if !ulubione.isEmpty {
						Section {
							LazyVGrid(columns: columns, spacing: 10) {
								ForEach(ulubione.filter { auth.canAccessDrink($0) }) { drink in
									kafelekDrinka(drink)
								}
							}
						} header: {
							HStack {
								Text("Ulubione:").textCase(.uppercase)
									.font(.title2)
									.fontWeight(.light)
									.foregroundStyle(Color.primary)
								Spacer()
							}
							.padding(.top, 20)
						}
					}

					// MARK: - POLECANE (losowane codziennie)
					if !polecaneDzisiaj.isEmpty {
						Section {
							LazyVGrid(columns: recommendedColumns, spacing: 10) {
								ForEach(polecaneDzisiaj) { drink in
									kafelekDrinka(drink)
								}
							}
						} header: {
							HStack {
								Text("Polecane:").textCase(.uppercase)
									.font(.title2)
									.fontWeight(.light)
									.foregroundStyle(Color.primary)
								Spacer()
							}
							.padding(.top, 20)
						}
					}
				} /// VStack END
				.padding(.horizontal, 12)
			} /// ScrollView END
			.scrollContentBackground(.hidden)
			.safeAreaInset(edge: .bottom) {
				Color.clear.frame(height: 30)
			}
			.background(Back_V().ignoresSafeArea())
			.navigationViewStyle(.automatic)
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				// Własny tytuł zamiast systemowego navigationTitle: tło to losowy,
				// niekontrolowany gradient (Back_V) — domyślny kolor tekstu (Color.primary,
				// czarny/biały zależnie od trybu) bywał niewidoczny na niektórych zestawieniach
				// kolorów, zwłaszcza w trybie ciemnym. Biały tekst + poświata (jak przy nazwach
				// kafelków) gwarantuje czytelność niezależnie od tła i trybu.
				ToolbarItem(placement: .principal) {
					Text(jezykAplikacji == "pl" ? "Drinkoteka" : "Drinkotheque")
						.font(.largeTitle)
						.fontWeight(.light)
						.foregroundStyle(Color.primary)
						.shadow(color: .black.opacity(0.6), radius: 6)
				}
			}
			.toolbarBackground(.visible, for: .navigationBar)
			.toolbarBackground(Material.thickMaterial, for: .navigationBar)
			.sheet(isPresented: $pokazPremium) {
				PremiumInfo_V(opis: "Ten drink jest dostępny w planie Premium. Wykup Premium, aby zobaczyć przepis.")
			}
		}
	}
		// Funkcja wyboru alko.
	func wyborAlko(wybor: alkGlownyEnum) {
		filtrAlkGlownyRum = false
		filtrAlkGlownyWhiskey = false
		filtrAlkGlownyTequila = false
		filtrAlkGlownyBrandy = false
		filtrAlkGlownyGin = false
		filtrAlkGlownyVodka = false
		filtrAlkGlownyChampagne = false
		filtrAlkGlownyInny = false
		
		filtrSlodkoscNieSlodki = true
		filtrSlodkoscLekkoSlodki = true
		filtrSlodkoscSlodki = true
		filtrSlodkoscBardzoSlodki = true
		
		filtrMocBezalk = true
		filtrMocDelik = true
		filtrMocSredni = true
		filtrMocMocny = true
		
		switch wybor {
			case .brandy: filtrAlkGlownyBrandy = true
			case .champagne: filtrAlkGlownyChampagne = true
			case .gin: filtrAlkGlownyGin = true
			case .inny: filtrAlkGlownyInny = true
			case .rum: filtrAlkGlownyRum = true
			case .tequila: filtrAlkGlownyTequila = true
			case .vodka: filtrAlkGlownyVodka = true
		case .whiskey: filtrAlkGlownyWhiskey = true
		}
	}

		// MARK: - KAFELEK DRINKA (Polecane/Ulubione)
	@ViewBuilder
	private func kafelekDrinka(_ drink: Dr_M) -> some View {
		let zablokowany = !auth.mozeOtworzyc(drink)
		return ZStack {
			Rectangle()
				.foregroundStyle(.ultraThinMaterial)
			ZStack {
				VStack {
					Spacer()
					Rectangle()
						.foregroundStyle(.thinMaterial)
						.frame(height: 30)
				}
			}

			DrinkotekaImage_V(nazwa: drink.drFoto, fallback: drink.drSzklo.foto)
				.aspectRatio(contentMode: .fit)
				.padding(32)
				.offset(x: 0, y: -12)
				.saturation(zablokowany ? 0 : 1)

			if zablokowany {
				VStack {
					HStack {
						Spacer()
						Image(systemName: "lock.fill")
							.resizable()
							.scaledToFit()
							.frame(width: 24, height: 24)
							.foregroundStyle(.secondary.opacity(0.5))
							.padding(10)
					}
					Spacer()
				}
			}

			VStack {
				Spacer()
				Text(drink.drNazwa.uppercased())
					.font(.caption2)
					.fontWeight(.medium)
					.foregroundStyle(Color.primary)
					.shadow(color: .gray, radius: 10)
					.shadow(color: .gray, radius: 5)
			}
			.padding(.bottom, 6)

			if auth.mozeOtworzyc(drink) {
				NavigationLink(destination: Drink_V(drink: drink)) {
					Rectangle()
						.fill(Color.clear)
				}
			} else {
				Button {
					pokazPremium = true
				} label: {
					Rectangle()
						.fill(Color.clear)
				}
			}
		}
		.aspectRatio(1, contentMode: .fit)
		.mask(RoundedRectangle(cornerRadius: 6))
		.overlay(RoundedRectangle(cornerRadius: 6).stroke(.white, lineWidth: 1))
		.opacity(zablokowany ? 0.35 : 1)
	}
}

#Preview {
	Home_V(activeTab: .constant(.home))
}
