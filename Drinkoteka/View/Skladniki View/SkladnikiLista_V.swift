import SwiftData
import SwiftUI

struct SkladnikiLista_V: View {
	@Environment(\.modelContext) private var modelContext
	
	@Query(sort: \Dr_M.drNazwa) private var drinki: [Dr_M]
	@Query(sort: \Skl_M.sklNazwa) private var skladniki: [Skl_M]
	
//	var skladniki = sklMockArray()
	
	@AppStorage("opcjonalneWymagane") var opcjonalneWymagane: Bool = false
	@AppStorage("zamiennikiDozwolone") var zamiennikiDozwolone: Bool = false
	@AppStorage("tylkoUlubione") var tylkoUlubione: Bool = false
	@AppStorage("tylkoDostepne") var tylkoDostepne: Bool = false
	
	@State var szukaj: String = ""
	@State var sortowanieAlfabetyczne = true

//	private var totalZamienniki: Int {
//		skladniki.reduce(0) { $0 + $1.zamienniki.count }
//	}
	
	var skladnikiFiltered: [Skl_M] {
		if szukaj.isEmpty {
			return skladniki
		} else {
			return skladniki.filter {
				$0.sklNazwa.localizedCaseInsensitiveContains(szukaj)
			}
		}
	}
	
	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
					// MARK: - POLE WYSZUKIWANIA
				SearchBar_V(searchText: $szukaj)
					.listRowBackground(Color.white.opacity(0.3))
				
				List {
					if sortowanieAlfabetyczne {
							// MARK: - Alfabet
						ForEach(skladnikiFiltered) { skladnik in
							NavigationLink(
								destination: Skladnik_V(skladnik: skladnik),
								label: {
									SkladnikListaRow(skladnik: skladnik)
								})
							.listRowBackground(Color.white.opacity(0.4))
							.buttonStyle(.plain)
						}
					} else {
							// MARK: - KATEGORIE
						ForEach(sklKatEnum.allCases, id: \.self) { kategoria in
							let macierz = skladnikiFiltered.filter { $0.sklKat == kategoria }
							if !macierz.isEmpty {
								Section {
										// MARK: - SKLADNIKI
									ForEach(macierz) { skladnik in
										NavigationLink(
											destination: Skladnik_V(skladnik: skladnik),
											label: {
												SkladnikListaRow(skladnik: skladnik)
											})
										.listRowBackground(Color.white.opacity(0.4))
										.buttonStyle(.plain)
									}
								} header: {
									HStack(alignment: .firstTextBaseline, spacing: 0) {
										Text("\(kategoria.rawValue) ".uppercased())
											.font(.title2)
										Text("\(macierz.count) skł.")
											.font(.footnote)
										Spacer()
									}
									.fontWeight(.light)
									.foregroundColor(Color.primary)
									.listRowBackground(Color.white.opacity(0.7))
									.padding(.horizontal, 12)
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
					// MARK: - TOOLBAR
				ToolbarItem(placement: .navigationBarLeading) {
					HStack{
							// Przycisk zamienników
						Button {
							zamiennikiDozwolone.toggle()
							setAllBraki(modelContext: modelContext)
						} label: {
							Image(systemName: zamiennikiDozwolone ? "repeat.circle.fill" : "repeat.circle")
								.foregroundStyle(zamiennikiDozwolone ? Color.accent : Color.secondary)
						}
						
							// Przycisk resetu
						Button {
							wylaczWszystkieSkladniki(context: modelContext)
						} label: {
							Image(systemName: "checkmark.circle")
								.foregroundStyle(Color.secondary)
						}
						
					}
				}
				ToolbarItem(placement: .navigationBarTrailing) {
					HStack{
							// Przycisk sortowania
						HStack(spacing: 0) {
							Button { /// Przycisk filtra
								sortowanieAlfabetyczne.toggle()
							} label: {
								Image(systemName: sortowanieAlfabetyczne ? "characters.uppercase" : "square.3.layers.3d")
									.font(.headline)
							}
						}
					}
				}
			}
			.toolbarBackgroundVisibility(.visible)
			.toolbarBackground(Material.thinMaterial)
			.navigationTitle("Składniki")
		}
	}
}

// MARK: - SKLADNIK ROW
private func SkladnikListaRow(skladnik: Skl_M) -> some View {
	HStack {
			// MARK: - IKONKA
		ZStack {
			Circle()
				.fill(.regularMaterial)
				.stroke(skladnik.getKolor(), lineWidth: skladnik.sklStan.stan ? 2 : 1)
			
			Image(!skladnik.sklFoto.isEmpty ? skladnik.sklFoto : "butelka")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: 35, height: 35)
				.clipShape(Circle())
		}
		.frame(width: 50, height: 50)
		
		Divider().frame(height: 50)
		
		// MARK: - NAZWA
		VStack(alignment: .leading, spacing: 4) {
			HStack(spacing: 0) {
				Text("\(skladnik.sklNazwa)")
					.font(.headline)
					.foregroundColor(.primary)
					.multilineTextAlignment(.leading)
				Spacer()
			}
			
			Divider()
				// MARK: - DANE
			HStack(spacing: 0) {
				Text("\(skladnik.sklProc)% ")
				Text("\(skladnik.sklKal) kCal.")
				Spacer()
			}
			.font(.footnote)
		}
		
		Divider().frame(height: 50)

		IkonaJestBrak_V(skladnik: skladnik, wielkosc: 26, wlaczTrybZamiennikow: true)
	}
	.frame(maxWidth: .infinity)
}

#Preview {
	NavigationStack {
		SkladnikiLista_V()
	}
}
