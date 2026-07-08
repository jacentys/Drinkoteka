// Ekran startowy: kafelki wg głównego alkoholu (przełączają zakładkę na Drinki z filtrem)
// oraz sekcja polecanych drinków.
import SwiftData
import SwiftUI

struct Home_V: View {
	@Binding var activeTab: Tab
	@Environment(\.modelContext) private var modelContext
	@Query(
		filter: #Predicate<Dr_M> { $0.drPolecany == true },
		sort: \Dr_M.drNazwa
	)
	private var drinki: [Dr_M]
	
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

	var body: some View {
		NavigationView {
			VStack {
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
							} /// KONIEC FOREACH
						} /// KONIEC LAZYVSTACK
					} /// KONIEC VSCROLL
					.scrollContentBackground(.hidden)
					.frame(height: 150)
				} header: {
					HStack {
						Text("Według alkoholu").textCase(.uppercase)
							.font(.headline)
							.foregroundStyle(Color.secondary)
						Spacer()
					}
				}
				
				// MARK: - POLECANE
				Section {
					ScrollView {
						LazyVGrid(columns: columns, spacing: 10) {
							ForEach(drinki.filter { auth.canAccessDrink($0) }) { drink in
									// MARK: - ELEMENT
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
									
									let zablokowany = !auth.mozeOtworzyc(drink)

									DrinkotekaImage_V(nazwa: drink.drFoto, fallback: drink.drSzklo.foto)
										.aspectRatio(contentMode: .fit)
										.padding(32)
										.offset(x: 0, y: -12)
										.saturation(zablokowany ? 0 : 1)
										.opacity(zablokowany ? 0.3 : 1)

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
											.foregroundStyle(zablokowany ? .secondary : .primary)
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
									
								} /// KONIEC ELEMENTU
								.aspectRatio(1, contentMode: .fit)
								.mask(RoundedRectangle(cornerRadius: 6))
								.overlay(RoundedRectangle(cornerRadius: 6).stroke(.white, lineWidth: 1))
							}
						}
					} /// KONIEC SCROLL
					.scrollContentBackground(.hidden)
				} header: {
					HStack {
						Text("Polecane:").textCase(.uppercase)
							.font(.headline)
							.foregroundStyle(Color.secondary)
						Spacer()
					}
				}
			} /// VStack END
			.padding(.horizontal, 12)
			.background(Back_V().ignoresSafeArea())
			.navigationViewStyle(.automatic)
			.navigationTitle("Drinkotheque")
			.toolbarBackground(.visible, for: .navigationBar)
			.toolbarBackground(Material.thinMaterial, for: .navigationBar)
			.sheet(isPresented: $pokazPremium) {
				PremiumInfo_V(opis: "Ten drink jest dostępny w planie Premium. Odblokuj Premium kodem aktywacyjnym, aby zobaczyć przepis.")
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
}

#Preview {
	Home_V(activeTab: .constant(.home))
}
