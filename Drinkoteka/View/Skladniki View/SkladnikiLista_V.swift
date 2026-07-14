// Lista składników (barek): alfabetycznie lub wg kategorii, przełącznik zamienników.
import SwiftData
import SwiftUI

struct SkladnikiLista_V: View {
	@Environment(\.modelContext) private var modelContext
	
	@Query(sort: \Dr_M.drNazwa) private var drinki: [Dr_M]
	@Query(sort: \Skl_M.sklNazwa) private var skladniki: [Skl_M]
	
	
	@AppStorage("opcjonalneWymagane") var opcjonalneWymagane: Bool = false
	@AppStorage("zamiennikiDozwolone") var zamiennikiDozwolone: Bool = false
	@AppStorage("tylkoUlubione") var tylkoUlubione: Bool = false
	@AppStorage("tylkoDostepne") var tylkoDostepne: Bool = false
	
	@State var szukaj: String = ""
	@State var sortowanieAlfabetyczne = true
	@State private var toastMessage: String? = nil

	
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
										Text(LocalizedStringKey(kategoria.opis))
											.textCase(.uppercase)
											.font(.title2)
										Text(" \(macierz.count) ")
											.font(.title2)
										Text("skł.")
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
				.safeAreaInset(edge: .bottom) {
					Color.clear.frame(height: 30)
				}
			}
			.background(Back_V().ignoresSafeArea())
			.toast(message: $toastMessage)

			.toolbar {
					// MARK: - TYTUŁ (jak "Drinkotheque" na ekranie głównym)
				ToolbarItem(placement: .principal) {
					Text("Składniki")
						.font(.largeTitle)
						.fontWeight(.light)
						.foregroundStyle(Color.primary)
						.shadow(color: .black.opacity(0.6), radius: 6)
				}

					// MARK: - TOOLBAR
				// Tylko ikona (jak gwiazdka "ulubione" na ekranie Drinki) — zwalnia miejsce
				// dla większego, spójnego tytułu na środku paska nawigacji.
				ToolbarItem(placement: .navigationBarLeading) {
					Button {
						zamiennikiDozwolone.toggle()
						setAllBraki(modelContext: modelContext)
						toastMessage = zamiennikiDozwolone ? "Uwzględniam zamienniki" : "Bez zamienników"
					} label: {
						Image(systemName: zamiennikiDozwolone ? "repeat.circle.fill" : "repeat.circle")
							.foregroundStyle(zamiennikiDozwolone ? Color.accent : Color.secondary)
					}
					.accessibilityLabel("Dopuszczaj zamienniki")
				}
				ToolbarItem(placement: .navigationBarTrailing) {
					Picker("", selection: $sortowanieAlfabetyczne) {
						Image(systemName: "textformat.abc").tag(true)
						Image(systemName: "square.3.layers.3d").tag(false)
					}
					.pickerStyle(.segmented)
					.frame(width: 90)
				}
			}
			.toolbarBackground(.visible, for: .navigationBar)
			.toolbarBackground(Material.thickMaterial, for: .navigationBar)
			.navigationBarTitleDisplayMode(.inline)
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
