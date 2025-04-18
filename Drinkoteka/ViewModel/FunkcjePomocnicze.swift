import SwiftUI

	// MARK: STRING TO DRINK KAT
func stringToDrinkKat(string: String) -> drKatEnum {
	let cleanedString = string.trimmingCharacters(in: .punctuationCharacters)
	switch cleanedString {
		case "koktail": return .koktail
		case "shot": return .shot
		default: return .brakDanych
	}
}

	// MARK: STRING -> MIARA
func strtoMiaraEnum(string: String) -> miaraEnum {
	let strClean = string.trimmingCharacters(in: .punctuationCharacters.union(.whitespacesAndNewlines)).lowercased()
	for jednostka in miaraEnum.allCases {
		if String(describing: jednostka).trimmingCharacters(in: .punctuationCharacters.union(.whitespacesAndNewlines)).lowercased() == strClean {
			return jednostka
		}
	}
	return .brak
} // STRING -> jednEnum


// MARK: STRING -> COLOR
func stringToColor(_ kolorString: String?) -> Color {

	if let tekstVar = kolorString {
			// Usuwanie znaków diakrytycznych (np. ą -> a, ó -> o)
		let bezDiakrytycznych = tekstVar.folding(options: .diacriticInsensitive, locale: .current).lowercased()

			// Usuwanie wszystkich znaków innych niż małe litery a-z i cyfry 0-9
		let tekst = bezDiakrytycznych.filter { $0.isLetter || $0.isNumber }
		return Color.white
//		if let color = UIColor(named: tekst) {
//			return Color(color)
//		}
	}
	return Color.white
}

	// MARK: STRING TO DRINK SLODYCZ
func stringToDrinkSlodycz(_ tekst: String?) -> drSlodyczEnum {
	switch tekst {
		case "Nie Słodki": return .nieSlodki
		case "Lekko Słodki": return .lekkoSlodki
		case "Słodki": return .slodki
		case "Bardzo Słodki": return .bardzoSlodki
		default: return .brakDanych
	}
}

	// MARK: STRING TO SZKLO
func stringToSzklo(string: String) -> szkloEnum {
	let cleanedString = string.trimmingCharacters(in: .punctuationCharacters)

	switch cleanedString {
		case "collins": return .collins
		case "whiskey": return .whiskey
		case "oldFashioned": return .oldFashioned
		case "koktailowy": return .koktailowy
		case "szampan": return .szampan
		case "wino": return .wino
		case "margarita": return .margarita
		case "kieliszek": return .kieliszek
		default: return .inne
	}
}

	// MARK: STRING TO DR KAT
func stringToDrKat(_ string: String) -> drKatEnum {
	let cleanedString = string.trimmingCharacters(in: .punctuationCharacters)
	
	switch cleanedString {
		case "koktail": return .koktail
		case "shot": return .shot
		default: return .brakDanych
	}
}

	// MARK: SET MOC DRINKA
func setMocDrinka(procenty: Int) -> drMocEnum {
	if (procenty == 0) {return .bezalk}
	if (procenty > 0 && procenty < drMocEnum.sredni.start) { return .delik}
	if (procenty >= drMocEnum.sredni.start && procenty < drMocEnum.mocny.start) { return .sredni}
	if (procenty >= drMocEnum.mocny.start) { return .mocny }
	return .brakDanych
}


// MARK: MIARA ODMIANY
func miara(miara: miaraEnum, ilosc: String) -> String {
	switch miara {
		case .gr: return "gr."
		case .ml: return "ml."
		case .sztuka: return "szt."
		case .dopelnienie: return "dopełnienie"
		case .odrobina:
			switch ilosc {
				case "1": return "odrobina"
				case "2", "3", "4": return "odrobiny"
				default: return "odrobin"
			}
		case .szczypta:
			switch ilosc {
				case "1": return "szczypta"
				case "2", "3", "4": return "szczypty"
				default: return "szczypt"
			}
		case .galazka:
			switch ilosc {
				case "1": return "gałązka"
				case "2", "3", "4": return "gałązki"
				default: return "gałązek"
			}
		case .kawalek:
			switch ilosc {
				case "1": return "kawałek"
				case "2", "3", "4": return "kawałki"
				default: return "kawałków"
			}
		case .kropla:
			switch ilosc {
				case "1": return "kropla"
				case "2", "3", "4": return "krople"
				default: return "kropli"
			}
		case .kostka:
			switch ilosc {
				case "1": return "kostka"
				case "2", "3", "4": return "kostki"
				default: return "kostek"
			}
		case .listek:
			switch ilosc {
				case "1": return "listek"
				case "2", "3", "4": return "listki"
				default: return "listków"
			}
		default:
			return ""
	}
}

// MARK: CHECKBOX
struct iOSCheckboxToggleStyle: ToggleStyle {
	func makeBody(configuration: Configuration) -> some View {
		Button(action: {
			configuration.isOn.toggle()
		}, label: {
			HStack {
				configuration.label
					.foregroundStyle(Color.secondary)
				Spacer()
				Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
//					.foregroundColor(configuration.isOn ? Color.accent : Color.secondary)
			}
		})
	}
}

// MARK: ODMIANA DRINKÓW
func odmianaDrinkow(_ ilosc: Int) -> String {
	if ilosc < 1 { return "brak drinków" }
	if ilosc == 1 { return "jeden drink" }
	else if (ilosc > 1 && ilosc < 5) { return "\(ilosc) drinki" }
	else { return "\(ilosc) drinków" }
}

// MARK: ODMIANA SKŁADNIKÓW
func odmianaSkladnikow(_ ilosc: Int) -> String {
	if ilosc == 0 { return "Masz wszystkie skł." }
	else { return "Brak \(ilosc) skł." }
}
