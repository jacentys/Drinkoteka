import SwiftUI

struct DrinkFiltry_V: View {
	enum blad {
		case alkGlowny
		case slodkosc
		case moc
	}

	@Environment(\.dismiss) var dismiss

	@AppStorage("zalogowany") var zalogowany: Bool?

	@AppStorage("sortowEnum") var sortowEnum: sortEnum?
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
	@AppStorage("zamiennikiDozwolone") var zamiennikiDozwolone: Bool = false
	@AppStorage("tylkoUlubione") var tylkoUlubione: Bool = false
	@AppStorage("tylkoDostepne") var tylkoDostepne: Bool = false

	@State var rodzajBledu: blad = blad.alkGlowny
	@State var pokazBlad: Bool = false

	@State var toggleAlkGlowny: Bool = true
	@State var toggleSlodkosc: Bool = true
	@State var toggleMoc: Bool = true

	@State var allAlkGlowny: Bool = true
	@State var allSlodkosc: Bool = true
	@State var allMoc: Bool = true

	let paddingHoriz: CGFloat = 20
	let paddingVert: CGFloat = 6


	var body: some View {
		NavigationStack {
			ScrollView {
				VStack {
						// MARK: - SORTOWANIE
					GroupBox(label: Label("Sortowanie", systemImage: "line.3.horizontal.decrease")
						.foregroundColor(.accent)
						.font(.headline)
						.fontWeight(.light))
					{
						VStack(spacing: 6) {
							HStack {
								Picker("Sortuj wg.", selection: $sortowEnum) {
									Text("Nazwa").tag(sortEnum.nazwa)
									Text("Słodkość").tag(sortEnum.slodycz)
									Text("Moc").tag(sortEnum.procenty)
									Text("Ilość Kalorii").tag(sortEnum.kcal)
									Text("Skład").tag(sortEnum.sklad)
								}
									//							.onChange(of: pref.sortowEnum) { oldValue, newValue in
									//								drClass.sortujDrinki()

								Button {
									sortowRosn.toggle()
								} label: {
									Image(systemName: sortowRosn ? "chevron.up" : "chevron.down")
										.foregroundStyle(Color.accent)
								}
							}
							Divider()
							Text("Sortuj wg. nazwy, słodkości, zawartości alkoholu, kalorii lub ilości składników dostępnych do zrobienia drinka.\nKliknij na strzałkę aby zmienić kierunek sortowania")
								.padding(.top, 8)
								.foregroundStyle(.secondary)
								.font(.footnote)
								.multilineTextAlignment(.center)
						}
						.padding(.horizontal, paddingHoriz)
						.padding(.vertical, paddingVert)
					}
					.backgroundStyle(.regularMaterial)

						// MARK: - ALKOHOL GŁÓWNY
					GroupBox(label: Label("Alkohol główny", systemImage: "bubbles.and.sparkles.fill")
						.foregroundColor(.accent)
						.font(.headline)
						.fontWeight(.light))
					{
						VStack(spacing: 6) {
							HStack {
								Spacer()
								Button(action: {
									toggleAlkGlowny.toggle()
									setAllAlkGlownyTrue()
								}) {
									Image(systemName: "checkmark.square")
								}
								.foregroundStyle(Color.secondary)
							}


							Toggle(isOn: $filtrAlkGlownyRum) {
								Text(alkGlownyEnum.rum.opis)
							}
							.onChange(of: filtrAlkGlownyRum) { _, _ in SprawdzCzyJestJeden() }

							Toggle(isOn: $filtrAlkGlownyWhiskey) {
								Text(alkGlownyEnum.whiskey.opis)
							}
							.onChange(of: filtrAlkGlownyWhiskey) { _, _ in SprawdzCzyJestJeden() }

							Toggle(isOn: $filtrAlkGlownyTequila) {
								Text(alkGlownyEnum.tequila.opis)
							}
							.onChange(of: filtrAlkGlownyTequila) { _, _ in SprawdzCzyJestJeden() }

							Toggle(isOn: $filtrAlkGlownyBrandy) {
								Text(alkGlownyEnum.brandy.opis)
							}
							.onChange(of: filtrAlkGlownyBrandy) { _, _ in SprawdzCzyJestJeden() }

							Toggle(isOn: $filtrAlkGlownyGin) {
								Text(alkGlownyEnum.gin.opis)
							}
							.onChange(of: filtrAlkGlownyGin) { _, _ in SprawdzCzyJestJeden() }

							Toggle(isOn: $filtrAlkGlownyVodka) {
								Text(alkGlownyEnum.vodka.opis)
							}
							.onChange(of: filtrAlkGlownyVodka) { _, _ in SprawdzCzyJestJeden() }

							Toggle(isOn: $filtrAlkGlownyChampagne) {
								Text(alkGlownyEnum.champagne.opis)
							}
							.onChange(of: filtrAlkGlownyChampagne) { _, _ in SprawdzCzyJestJeden() }

							Toggle(isOn: $filtrAlkGlownyInny) {
								Text(alkGlownyEnum.inny.opis)
							}
							.onChange(of: filtrAlkGlownyInny) { _, _ in SprawdzCzyJestJeden() }

							Divider()

							Text("Wybierz alkohol, który ma być głównym składnikiem drinków")
								.padding(.top, 8)
								.foregroundStyle(.secondary)
								.font(.footnote)
								.multilineTextAlignment(.center)
						}
						.padding(.horizontal, paddingHoriz)
						.padding(.vertical, paddingVert)
					}
					.toggleStyle(iOSCheckboxToggleStyle())
					.backgroundStyle(.regularMaterial)

						// MARK: - SŁODKOŚĆ
					GroupBox(label: Label("Słodkość drinka", systemImage: "drop.degreesign.fill")
						.foregroundColor(.accent)
						.font(.headline)
						.fontWeight(.light))
					{
						VStack(spacing: 6) {
							HStack {
								Spacer()
								Button(action: {
									toggleSlodkosc.toggle()
									setAllSlodkoscTrue()
								}) {
									Image(systemName: "checkmark.square")
										.foregroundStyle(Color.secondary)
								}
							}

							Toggle(isOn: $filtrSlodkoscNieSlodki) {
								Text(drSlodyczEnum.nieSlodki.rawValue)
							}
							.onChange(of: filtrSlodkoscNieSlodki) { _, _ in SprawdzCzyJestJeden() }

							Toggle(isOn: $filtrSlodkoscLekkoSlodki) {
								Text(drSlodyczEnum.lekkoSlodki.rawValue)
							}
							.onChange(of: filtrSlodkoscLekkoSlodki) { _, _ in SprawdzCzyJestJeden() }

							Toggle(isOn: $filtrSlodkoscSlodki) {
								Text(drSlodyczEnum.slodki.rawValue)
							}
							.onChange(of: filtrSlodkoscSlodki) { _, _ in SprawdzCzyJestJeden() }

							Toggle(isOn: $filtrSlodkoscBardzoSlodki) {
								Text(drSlodyczEnum.bardzoSlodki.rawValue)
							}
							.onChange(of: filtrSlodkoscBardzoSlodki) { _, _ in SprawdzCzyJestJeden() }

							Divider()

							Text("Wybierz poziom słodkości drinka")
								.padding(.top, 8)
								.foregroundStyle(.secondary)
								.font(.footnote)
								.multilineTextAlignment(.center)
						}
						.padding(.horizontal, paddingHoriz)
						.padding(.vertical, paddingVert)
					}
					.toggleStyle(iOSCheckboxToggleStyle())
					.backgroundStyle(.regularMaterial)

						// MARK: - MOC
					GroupBox(label: Label("Moc drinka", systemImage: "bolt.fill")
						.foregroundColor(.accent)
						.font(.headline)
						.fontWeight(.light))
					{
						VStack(spacing: 6) {
							HStack {
								Spacer()
								Button(action: {
									toggleMoc.toggle()
									setAllMocTrue()
								}) {
									Image(systemName: "checkmark.square")
										.foregroundStyle(Color.secondary)
								}
							}


							Toggle(isOn: $filtrMocBezalk) {
								Text("Bezalkoholowy (0%)")
							}
							.onChange(of: filtrMocBezalk) { _, _ in SprawdzCzyJestJeden() }

							Toggle(isOn: $filtrMocDelik) {
								Text("Delikatny (1% - \(drMocEnum.sredni.start-1)%)")
							}
							.onChange(of: filtrMocDelik) { _, _ in SprawdzCzyJestJeden() }

							Toggle(isOn: $filtrMocSredni) {
								Text("Średni (\(drMocEnum.sredni.start)% - \(drMocEnum.mocny.start-1)%)")
							}
							.onChange(of: filtrMocSredni) { _, _ in SprawdzCzyJestJeden() }

							Toggle(isOn: $filtrMocMocny) {
								Text("Mocny (powyżej \(drMocEnum.mocny.start-1)%")
							}
							.onChange(of: filtrMocMocny) { _, _ in SprawdzCzyJestJeden() }

							Divider()

							Text("Wybierz poziom zawartości alkoholu w drinku")
								.padding(.top, 8)
								.foregroundStyle(.secondary)
								.font(.footnote)
								.multilineTextAlignment(.center)
						}
						.padding(.horizontal, paddingHoriz)
						.padding(.vertical, paddingVert)
					}
					.toggleStyle(iOSCheckboxToggleStyle()) // Moc
				}
					// MARK: - CAŁY VSTACK
				.padding(30)
					//			.frame(minWidth: .infinity)
				.backgroundStyle(.regularMaterial)
				.navigationTitle("Filtry")
					// MARK: - ALERT
				.alert(isPresented: $pokazBlad) {
					switch rodzajBledu {
						case .alkGlowny:
							Alert(
								title: Text("Mały błąd"),
								message: Text("Co najmniej jeden z alkoholi głównych powinien być wybrany. \nW innym wypadku wyświetlana \nlista będzie pusta"),
								dismissButton: .default(Text("OK")))

						case .slodkosc:
							Alert(
								title: Text("Mały błąd"),
								message: Text("Co najmniej jeden z poziomów słodkości powinien być wybrany. \nW innym wypadku wyświetlana \nlista będzie pusta"),
								dismissButton: .default(Text("OK")))
						case .moc:
							Alert(
								title: Text("Mały błąd"),
								message: Text("Co najmniej jeden z poziomów mocy drinka powinien być wybrany. \nW innym wypadku wyświetlana \nlista będzie pusta"),
								dismissButton: .default(Text("OK")))
					}
				}

					//			.toolbar {
					// MARK: - TOOLBAR
				.toolbar {
					ToolbarItem(placement: .destructiveAction) {
						Button {
							ResetujFiltr()
						} label: {
							Image(systemName: "arrow.trianglehead.counterclockwise")
						}
					}

					ToolbarItem(placement: .cancellationAction) {
						Button {
							dismiss()
						} label: {
							Image(systemName: "xmark")
						}
					}
				}
			}
		}
		}

		// MARK: - FUNKCJE

	func SprawdzCzyJestJeden() {
		if !(filtrAlkGlownyRum || filtrAlkGlownyWhiskey || filtrAlkGlownyTequila || filtrAlkGlownyBrandy || filtrAlkGlownyGin || filtrAlkGlownyVodka || filtrAlkGlownyChampagne || filtrAlkGlownyInny)
		{
			rodzajBledu = .alkGlowny
			pokazBlad = true
		} else if !(filtrSlodkoscNieSlodki || filtrSlodkoscLekkoSlodki || filtrSlodkoscSlodki || filtrSlodkoscBardzoSlodki)
		{
			rodzajBledu = .slodkosc
			pokazBlad = true
		} else if !(filtrMocBezalk || filtrMocDelik || filtrMocSredni || filtrMocMocny)
		{
			rodzajBledu = .moc
			pokazBlad = true
		} else {
			pokazBlad = false
//			drClass.filtrujDrinki(pref: pref)
		}
	}

	func setAllAlkGlownyTrue() {
		if allAlkGlowny {
			filtrAlkGlownyRum = false
			filtrAlkGlownyWhiskey = true
			filtrAlkGlownyTequila = false
			filtrAlkGlownyBrandy = false
			filtrAlkGlownyGin = false
			filtrAlkGlownyVodka = false
			filtrAlkGlownyChampagne = false
			filtrAlkGlownyInny = false
		} else {
			filtrAlkGlownyRum = true
			filtrAlkGlownyWhiskey = true
			filtrAlkGlownyTequila = true
			filtrAlkGlownyBrandy = true
			filtrAlkGlownyGin = true
			filtrAlkGlownyVodka = true
			filtrAlkGlownyChampagne = true
			filtrAlkGlownyInny = true
		}
		allAlkGlowny.toggle()
	}

	func setAllSlodkoscTrue() {
		if allSlodkosc {
			filtrSlodkoscNieSlodki = false
			filtrSlodkoscLekkoSlodki = false
			filtrSlodkoscSlodki = true
			filtrSlodkoscBardzoSlodki = false
		} else {
			filtrSlodkoscNieSlodki = true
			filtrSlodkoscLekkoSlodki = true
			filtrSlodkoscSlodki = true
			filtrSlodkoscBardzoSlodki = true
		}
		allSlodkosc.toggle()
	}

	func setAllMocTrue() {
		if allMoc {
			filtrMocBezalk = false
			filtrMocDelik = true
			filtrMocSredni = false
			filtrMocMocny = false
		} else {
			filtrMocBezalk = true
			filtrMocDelik = true
			filtrMocSredni = true
			filtrMocMocny = true
		}
		allMoc.toggle()
	}

	func ResetujFiltr() {
		filtrAlkGlownyRum = true
		filtrAlkGlownyWhiskey = true
		filtrAlkGlownyTequila = true
		filtrAlkGlownyBrandy = true
		filtrAlkGlownyGin = true
		filtrAlkGlownyVodka = true
		filtrAlkGlownyChampagne = true
		filtrAlkGlownyInny = true
		filtrSlodkoscNieSlodki = true
		filtrSlodkoscLekkoSlodki = true
		filtrSlodkoscSlodki = true
		filtrSlodkoscBardzoSlodki = true
		filtrMocBezalk = true
		filtrMocDelik = true
		filtrMocSredni = true
		filtrMocMocny = true
//		drClass.filtrujDrinki(pref: pref)
	}
}

#Preview {
	NavigationStack {
		DrinkFiltry_V()
	}
}
