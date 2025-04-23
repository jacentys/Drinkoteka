import SwiftUI

struct DrinkFiltry_V: View {
	enum blad {
		case alkGlowny
		case slodkosc
		case moc
	}

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

//	@EnvironmentObject var drClass: DrClass
	@Environment(\.dismiss) var dismiss

	@State var rodzajBledu: blad = blad.alkGlowny
	@State var pokazBlad: Bool = false

	@State var toggleAlkGlowny: Bool = true
	@State var toggleSlodkosc: Bool = true
	@State var toggleMoc: Bool = true

	var body: some View {
		NavigationStack {
			Form{
				Section( // MARK: Sortowanie
					header: Text("Sortowanie"),
					footer: Text("Sortuj wg. nazwy, słodkości, zawartości alkoholu, kalorii lub ilości składników dostępnych do zrobienia drinka.\nKliknij na strzałki, aby zmienić kierunek sortowania")) {
						HStack {
							Picker("Sortowanie wg.", selection: $sortowEnum) {
								Text("Nazwa").tag(sortEnum.nazwa)
								Text("Słodkość").tag(sortEnum.slodycz)
								Text("Moc").tag(sortEnum.procenty)
								Text("Ilość Kalorii").tag(sortEnum.kcal)
								Text("Skład").tag(sortEnum.sklad)
							}
							.pickerStyle(.menu)
//							.onChange(of: pref.sortowEnum) { oldValue, newValue in
//								drClass.sortujDrinki()
//							}

							Button {
								sortowRosn.toggle()
							} label: {
								Image(systemName: "chevron.up")
									.foregroundStyle(sortowRosn ? Color.accent : Color.secondary)
									.font(sortowRosn ? .title : .caption)
								Image(systemName: "chevron.down")
									.foregroundStyle(sortowRosn ? Color.accent : Color.secondary)
									.font(!sortowRosn ? .title : .caption)
							}
						}
					} // Sortowanie

				Section( // MARK: Alkohol główny
					header: HStack {
						Text("Alkohol główny")
						Spacer()
						Button(action: {
							toggleAlkGlowny.toggle()
							setAllAlkGlownyTrue()
						}) {
							Image(systemName: filtrAlkGlownyRum && filtrAlkGlownyWhiskey && filtrAlkGlownyTequila && filtrAlkGlownyBrandy && filtrAlkGlownyGin && filtrAlkGlownyVodka && filtrAlkGlownyChampagne && filtrAlkGlownyInny ? "checkmark.square" : "square")
								.foregroundStyle(Color.secondary)
						}
					},
					footer: Text("Wybierz alkohol, który ma być głównym składnikiem drinków"))
				{
					Toggle(isOn: $filtrAlkGlownyRum) {
						Text(alkGlownyEnum.rum.rawValue)
					}
					.onChange(of: filtrAlkGlownyRum) { _, _ in SprawdzCzyJestJeden() }

					Toggle(isOn: $filtrAlkGlownyWhiskey) {
						Text(alkGlownyEnum.whiskey.rawValue)
					}
					.onChange(of: filtrAlkGlownyWhiskey) { _, _ in SprawdzCzyJestJeden() }

					Toggle(isOn: $filtrAlkGlownyTequila) {
						Text(alkGlownyEnum.tequila.rawValue)
					}
					.onChange(of: filtrAlkGlownyTequila) { _, _ in SprawdzCzyJestJeden() }

					Toggle(isOn: $filtrAlkGlownyBrandy) {
						Text(alkGlownyEnum.brandy.rawValue)
					}
					.onChange(of: filtrAlkGlownyBrandy) { _, _ in SprawdzCzyJestJeden() }

					Toggle(isOn: $filtrAlkGlownyGin) {
						Text(alkGlownyEnum.gin.rawValue)
					}
					.onChange(of: filtrAlkGlownyGin) { _, _ in SprawdzCzyJestJeden() }

					Toggle(isOn: $filtrAlkGlownyVodka) {
						Text(alkGlownyEnum.vodka.rawValue)
					}
					.onChange(of: filtrAlkGlownyVodka) { _, _ in SprawdzCzyJestJeden() }

					Toggle(isOn: $filtrAlkGlownyChampagne) {
						Text(alkGlownyEnum.champagne.rawValue)
					}
					.onChange(of: filtrAlkGlownyChampagne) { _, _ in SprawdzCzyJestJeden() }

					Toggle(isOn: $filtrAlkGlownyInny) {
						Text(alkGlownyEnum.inny.rawValue)
					}
					.onChange(of: filtrAlkGlownyInny) { _, _ in SprawdzCzyJestJeden() }
				}
				.toggleStyle(iOSCheckboxToggleStyle()) // Alkohol główny

				Section( // MARK: Słodkość
					header: HStack {
						Text("Słodkość drinka")
						Spacer()
						Button(action: {
							toggleSlodkosc.toggle()
							setAllSlodkoscTrue()
						}) {
							Image(systemName: filtrSlodkoscNieSlodki && filtrSlodkoscLekkoSlodki && filtrSlodkoscSlodki && filtrSlodkoscBardzoSlodki ? "checkmark.square" : "square")
								.foregroundStyle(Color.secondary)
						}
					},
					footer: Text("Wybierz poziom słodkości drinka"))
				{
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
				}
				.toggleStyle(iOSCheckboxToggleStyle()) // Słodkość

				Section( // MARK: Moc
					header: HStack {
						Text("Moc drinka")
						Spacer()
						Button(action: {
							toggleMoc.toggle()
							setAllMocTrue()
						}) {
							Image(systemName: filtrMocBezalk && filtrMocDelik && filtrMocSredni && filtrMocMocny ? "checkmark.square" : "square")
								.foregroundStyle(Color.secondary)
						}
					},
					footer: Text("Wybierz poziom zawartości alkoholu w drinku")) {
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
					}
					.toggleStyle(iOSCheckboxToggleStyle()) // Moc
			}
			.navigationTitle("Filtry")
#if os(iOS)
			.navigationBarTitleDisplayMode(.inline)
#endif
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
			} // MARK: Alert

			.toolbar {

#if os(macOS)
				ToolbarItem(placement: .automatic) {
					Button("Akcja") {
						print("Klik!")
					}
				}
#endif
#if os(iOS)
				ToolbarItem(placement: .navigationBarLeading) {
					HStack(spacing: 3) {
							// Przycisk resetu
						Button("Resetuj Filtry") {
							ResetujFiltr()
						}
							//						.buttonStyle(.borderedProminent)
					}
				}
				ToolbarItem(placement: .navigationBarTrailing) {
						// Przycisk preferencji
					Button {
						dismiss()
					} label: {
						Image(systemName: "xmark")
							//						Text("Zamknij")
					}
						//					.buttonStyle(.borderedProminent)
				}
#endif
			} // MARK: Toolbar
		}
	}

	func SprawdzCzyJestJeden() {
		if !(filtrAlkGlownyRum || filtrAlkGlownyWhiskey || filtrAlkGlownyTequila || filtrAlkGlownyBrandy || filtrAlkGlownyGin || filtrAlkGlownyVodka || filtrAlkGlownyChampagne || filtrAlkGlownyInny) {
			rodzajBledu = .alkGlowny
			pokazBlad = true
		} else if !(filtrSlodkoscNieSlodki || filtrSlodkoscLekkoSlodki || filtrSlodkoscSlodki || filtrSlodkoscBardzoSlodki) {
			rodzajBledu = .slodkosc
			pokazBlad = true
		} else if !(filtrMocBezalk || filtrMocDelik || filtrMocSredni || filtrMocMocny) {
			rodzajBledu = .moc
			pokazBlad = true
		} else {
			pokazBlad = false
//			drClass.filtrujDrinki(pref: pref)
		}
	}

	func setAllAlkGlownyTrue() {
		filtrAlkGlownyRum = true
		filtrAlkGlownyWhiskey = true
		filtrAlkGlownyTequila = true
		filtrAlkGlownyBrandy = true
		filtrAlkGlownyGin = true
		filtrAlkGlownyVodka = true
		filtrAlkGlownyChampagne = true
		filtrAlkGlownyInny = true
	}

	func setAllSlodkoscTrue() {
		filtrSlodkoscNieSlodki = true
		filtrSlodkoscLekkoSlodki = true
		filtrSlodkoscSlodki = true
		filtrSlodkoscBardzoSlodki = true
	}

	func setAllMocTrue() {
		filtrMocBezalk = true
		filtrMocDelik = true
		filtrMocSredni = true
		filtrMocMocny = true
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
		Text("Filtry")
//		DrinkFiltry()
	}
}
