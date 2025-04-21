import SwiftUI

	// MARK: CLEARSTR
func clearStr(_ tekst: String) -> String {
	let trimmed = tekst.trimmingCharacters(in: .punctuationCharacters.union(.whitespacesAndNewlines)).lowercased()
		// Usuwanie znaków diakrytycznych (np. ą -> a, ó -> o)
	let bezDiakrytycznych = trimmed.folding(options: .diacriticInsensitive, locale: .current)
		// Usuwanie wszystkich znaków innych niż małe litery a-z i cyfry 0-9
	let clear = bezDiakrytycznych.filter { $0.isLetter || $0.isNumber }
	return clear.replacingOccurrences(of: "ł", with: "l")
}

	// MARK: STRING -> ENUM DRINKA
func strToDrKatEnum(_ tekst: String) -> drKatEnum {
	let clear = clearStr(tekst)
	
	switch clear {
		case "koktail": return .koktail
		case "shot": return .shot
		default: return .brakDanych
	}
}
func strToDrSlodycz(_ tekst: String) -> drSlodyczEnum {
	let clear = clearStr(tekst)
	switch clear {
		case "nieslodki": return .nieSlodki
		case "lekkoslodki": return .lekkoSlodki
		case "slodki": return .slodki
		case "bardzoslodki": return .bardzoSlodki
		default: return .brakDanych
	}
}
func strToDrSzklo(_ tekst: String) -> szkloEnum {
	let clear = clearStr(tekst)
	switch clear {
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
func strToDrMoc(_ procenty: Int) -> drMocEnum {
	if (procenty == 0) {return .bezalk}
	if (procenty > 0 && procenty < drMocEnum.sredni.start) { return .delik}
	if (procenty >= drMocEnum.sredni.start && procenty < drMocEnum.mocny.start) { return .sredni}
	if (procenty >= drMocEnum.mocny.start) { return .mocny }
	return .brakDanych
}
func strToDrMoc(_ tekst: String) -> drMocEnum {
	let clear = clearStr(tekst)
	guard let procenty = Int(clear) else {
		print("Błąd: strToDrMoc string wejściowy \(tekst) to nie liczba")
		return drMocEnum.brakDanych
	}
	if (procenty == 0) {return .bezalk}
	if (procenty > 0 && procenty < drMocEnum.sredni.start) { return .delik}
	if (procenty >= drMocEnum.sredni.start && procenty < drMocEnum.mocny.start) { return .sredni}
	if (procenty >= drMocEnum.mocny.start) { return .mocny }
	return .brakDanych
}

	// MARK: STRING -> ENUM SKŁADNIKA
func strToSklKatEnum(_ tekst: String) -> sklKatEnum {
	let clear = clearStr(tekst)
	guard let kategoria = sklKatEnum(rawValue: clear) else {
		print("strToSklKatEnum niepoprawne dane: \(tekst)")
		return sklKatEnum.inne
	}
	return kategoria
}
func strToSklStanEnum(_ tekst: String) -> sklStanEnum {
	let clear = clearStr(tekst)
	guard let liczba = Int(clear) else {
		print("strToStanEnum tekst \(tekst) nie jest Int")
		return sklStanEnum.brak
	}
	if liczba == 1 { return sklStanEnum.jest }
	return sklStanEnum.brak
}
/// To jest chyba najlepiej zrobiona funkcja do konwersji.
func strToSklMiaraEnum(_ tekst: String) -> miaraEnum {
	let clear = clearStr(tekst)
	for jednostka in miaraEnum.allCases {
		if String(describing: jednostka).trimmingCharacters(in: .punctuationCharacters.union(.whitespacesAndNewlines)).lowercased() == clear {
			return jednostka
		}
	}
	return .brak
}

	// MARK: STRING -> BOOL
func strToBool(_ tekst: String) -> Bool {
	let clear = clearStr(tekst)
	guard let liczba = Int(clear) else {
		print("strToBool tekst \(tekst) nie jest int")
		if clear == "true" { return true }
		return false
	}
	if liczba == 1 { return true }
	return false
}
	// MARK: STRING -> COLOR
func strToColor(_ tekst: String) -> Color {
	let clear = clearStr(tekst)
	if let color = UIColor(named: clear) {
		return Color(color)
	}
	return Color.white
}
	// MARK: STRING -> DOUBLE
func stringToDouble(_ tekst: String) -> Double {
	
	if let numer = Double(tekst.trimmingCharacters(in: .whitespacesAndNewlines)) {
		return numer
	}
	return 0.0
}
	// MARK: STRING -> INT
func stringToInt(_ tekst: String) -> Int {
	if let numer = Int(tekst.trimmingCharacters(in: .whitespacesAndNewlines)) {
		return numer
	}
	return 0
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
func drOdm(_ ilosc: Int) -> String {
	if ilosc < 1 { return "brak drinków" }
	if ilosc == 1 { return "jeden drink" }
	else if (ilosc > 1 && ilosc < 5) { return "\(ilosc) drinki" }
	else { return "\(ilosc) drinków" }
}

	// MARK: ODMIANA SKŁADNIKÓW
func sklOdmiana(_ ilosc: Int) -> String {
	if ilosc == 0 { return "Masz wszystkie skł." }
	else { return "Brak \(ilosc) skł." }
}

	// MARK: ODMIANA MIAR
func miaraOdm(_ miara: miaraEnum, ilosc: String) -> String {
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

	// MARK: FORMATOWANIE CYFR
func formatNumber(_ liczba: Double) -> String {
	if liczba == 0 {
		return "Pusty"
	} else if liczba.truncatingRemainder(dividingBy: 1) == 0 {
		return String(Int(liczba)) // np. 5.0 → "5"
	} else {
		return String(format: "%.1f", liczba) // np. 5.3 → "5.3"
	}
}
