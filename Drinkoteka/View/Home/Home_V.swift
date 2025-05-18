import SwiftData
import SwiftUI

struct Home_V: View {
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
	
	let columns: [GridItem] = [GridItem(.adaptive(minimum: 150, maximum: 300), spacing: 12, alignment: nil)]
	
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
									
									NavigationLink(destination: {
										DrinkiListaAlkGl_V(alkGlowny: kategoria)
											.onAppear {
												wyborAlko(wybor: kategoria )
											}
									}
									) {
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
					.frame(height: 200)
				} header: {
					HStack {
						Text("Według alkoholu".uppercased())
							.font(.headline)
							.foregroundStyle(Color.secondary)
						Spacer()
					}
				}
				
				// MARK: - POLECANE
				Section {
					ScrollView {
						LazyVGrid(columns: columns, spacing: 10) {
							ForEach(drinki) { drink in
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
									
									Image(drink.drFoto)
										.resizable()
										.aspectRatio(contentMode: .fit)
										.padding(32)
										.offset(x: 0, y: -12)
									
									VStack {
										Spacer()
										Text(drink.drNazwa.uppercased())
											.font(.caption2)
											.fontWeight(.medium)
											.foregroundStyle(.primary)
											.shadow(color: .gray, radius: 10)
											.shadow(color: .gray, radius: 5)
									}
									.padding(.bottom, 6)
									
									NavigationLink(destination: Drink_V(drink: drink)) {
										Rectangle()
											.fill(Color.clear)
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
						Text("Polecane:".uppercased())
							.font(.headline)
							.foregroundStyle(Color.secondary)
						Spacer()
					}
				}
			} /// VStack END
			.padding(.horizontal, 12)
			.background(Back_V().ignoresSafeArea())
			.navigationViewStyle(.automatic)
			.navigationTitle("Drinkoteka")
			.toolbarBackgroundVisibility(.visible)
			.toolbarBackground(Material.thinMaterial)
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
	Home_V()
}
