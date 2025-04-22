import SwiftData
import SwiftUI

struct DrinkiListaView: View {

	@Query private var drinki: [Drink]
	@Query private var skladniki: [Skladnik]

	@EnvironmentObject var pref: PrefClass
	@EnvironmentObject var drClass: DrClass
	@EnvironmentObject var skladnikiClass: SklClass

	@State var pokazFiltr: Bool = false
	@State var drinkSearchString: String = ""


	var body: some View {
		NavigationStack {
			VStack {
//				Szukaj(searchTXT: $drinkSearchString)
				switch pref.sortowEnum {
					case .nazwa: // MARK: NAZWA
						SortNazwaView()

					case .slodycz: // MARK: SLODYCZ
						SortSlodyczView()

					case .procenty: // MARK: PROCENTY
						SortMocView()

					case .kcal: // MARK: KCAL
						SortNazwaView()

					case .sklad: // MARK: SKLAD
						SortSkladView()
				}
			}
			.background(Back().ignoresSafeArea())




				// MARK: TOOLBAR
			.toolbar {
					// Przyciski nawigacji lewo
				ToolbarItem(placement: .navigationBarLeading) {
					HStack(spacing: 5) {
							// Przycisk dostępnych
						Button {
							pref.dostepne.toggle()
								//							drClass.filtrujDrinki(pref: pref)
						} label: {
							Image(systemName: pref.dostepne ? "checkmark.circle.fill" : "checkmark.circle")
								.font(.title2)
								.foregroundStyle(pref.dostepne ? Color.accent : Color.secondary)
//								.shadow(radius: 5)
						}

							// Przycisk ulubionych
						Button {
							pref.ulubione.toggle()
//							drClass.filtrujDrinki(pref: pref)
						} label: {
							Image(systemName: pref.ulubione ? "star.circle.fill" : "star.circle")
								.font(.title2)
								.foregroundStyle(pref.ulubione ? Color.accent : Color.secondary)
//								.shadow(radius: 5)
						}

							// Przycisk opcjonalne
						Button {
							pref.opcjonalne.toggle()
							drClass.setWszystkieBraki()
//							drClass.filtrujDrinki(pref: pref)
						} label: {
							Image(systemName: pref.opcjonalne ? "list.bullet.circle.fill" : "list.bullet.circle")
								.font(.title2)
								.foregroundStyle(pref.opcjonalne ? Color.accent : Color.secondary)
//								.shadow(radius: 5)
						}

							// Przycisk zamienników
						Button {
							pref.zamienniki.toggle()
							drClass.setWszystkieBraki()
//							drClass.filtrujDrinki(pref: pref)
						} label: {
							Image(systemName: pref.zamienniki ? "repeat.circle.fill" : "repeat.circle")
								.font(.title2)
								.foregroundStyle(pref.zamienniki ? Color.accent : Color.secondary)
//								.shadow(radius: 5)
						}

					}
				}

					// Przyciski nawigacji prawo
				ToolbarItem(placement: .navigationBarTrailing) {
						// Przycisk preferencji
					Button {
						pokazFiltr.toggle()
					} label: {
						Text("Filtry")
					}
					.buttonStyle(.borderedProminent)
					.sheet(isPresented: $pokazFiltr) {
						DrinkFiltry()
							.presentationDetents([.large])
					}
				}
			}
			.toolbarBackgroundVisibility(.visible)
			.toolbarBackground(Material.thinMaterial)
			.navigationTitle("Drinki")




			// MARK: SEARCHABLE
			.searchable(
				text: $drinkSearchString
			) {
				ForEach (drClass.drFindedArray) { drink in
					DrinkiListaRowView(drSelID: drink.id)
				}
			}
			.onChange(of: drinkSearchString) { oldValue, newValue in
				drClass.drFindedArray = drClass.drArray
					.filter({ drink in
						drink.drNazwa.lowercased().contains(newValue.lowercased())
					})
			}
		}
	}
}
 
	// MARK: NAZWA LUB KALORIE
struct SortNazwaView: View {
	@EnvironmentObject var pref: PrefClass
	@EnvironmentObject var drClass: DrClass
	@EnvironmentObject var skladnikiClass: SklClass

	var body: some View {
		let macierz = drClass.filtrujDrinki(pref: pref)
			.sorted {
				if pref.sortowEnum == .nazwa {
					if pref.sortowRosn {
						return $0.drNazwa < $1.drNazwa  // Sortowanie według nazwy (rosnąco)
					} else {
						return $0.drNazwa > $1.drNazwa  // Sortowanie według nazwy (malejąco)
					}
				} else if pref.sortowEnum == .kcal {
					if pref.sortowRosn {
						return $0.drKalorie < $1.drKalorie  // Sortowanie według kalorii (rosnąco)
					} else {
						return $0.drKalorie > $1.drKalorie  // Sortowanie według kalorii (malejąco)
					}
				} else {
					return $0.drNazwa < $1.drNazwa
				}
			}
		if macierz.isEmpty {
				// Jeśli macierz jest pusta, wyświetlamy EmptyView lub inny widok
			return AnyView( EmptyView() )
		}

		return AnyView( // Jeśli macierz nie jest pusta, wyświetlamy dane w ScrollView
			ScrollView {
				Section {
					HStack(alignment: .firstTextBaseline, spacing: 0) {
						Text("\(macierz.count) ")
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
						ForEach(macierz) { drink in
							DrinkiListaRowView(drSelID: drink.id)
						}
					}
				}
				.padding(.bottom, 30)
			}
		)
	}
}

	// MARK: SORT SŁODYCZ
struct SortSlodyczView: View {
	@EnvironmentObject var pref: PrefClass
	@EnvironmentObject var drClass: DrClass
	@EnvironmentObject var skladnikiClass: SklClass
	
	var body: some View {
		ScrollView {

				// Posortowanie enumów
			let enumSorted = drSlodyczEnum.allCases.sorted {
				pref.sortowRosn ? $0.sort < $1.sort : $0.sort > $1.sort
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
								DrinkiListaRowView(drSelID: drink.id)
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

	// MARK: MOC
struct SortMocView: View {
	@EnvironmentObject var pref: PrefClass
	@EnvironmentObject var drClass: DrClass
	@EnvironmentObject var skladnikiClass: SklClass

	var body: some View {
		ScrollView {

				// Posortowanie enumów
			let enumSorted = drMocEnum.allCases.sorted {
				pref.sortowRosn ? $0.sort < $1.sort : $0.sort > $1.sort
			}
			ForEach(enumSorted, id: \.rawValue) { moc in
					let opis = moc.opisLong
					let przefiltrowane = drClass.filtrujDrinki(pref: pref)
					.filter { $0.drMoc == moc }
					.sorted {
						if pref.sortowRosn {
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
									DrinkiListaRowView(drSelID: drink.id)
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

	// MARK: SKLAD VIEW
struct SortSkladView: View {
	@EnvironmentObject var pref: PrefClass
	@EnvironmentObject var drClass: DrClass
	@EnvironmentObject var skladnikiClass: SklClass

	var body: some View {
		ScrollView {

			let zakres = drClass.brakMin...drClass.brakMax

			ForEach((zakres), id: \.self) { idx in
				let indeks = pref.sortowRosn ? idx : drClass.brakMax - idx

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
								DrinkiListaRowView(drSelID: drink.id)
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


#Preview {
	NavigationStack {
		DrinkiListaView()
	}
	.environmentObject(SklClass())
	.environmentObject(PrefClass())
	.environmentObject(DrClass(sklClass: SklClass(), pref: PrefClass()))
}
