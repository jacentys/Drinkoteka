import SwiftUI
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
typealias PlatformColor = UIColor
#elseif os(macOS)
import AppKit
typealias PlatformColor = NSColor
#endif

//@AppStorage("zalogowany") var zalogowany: Bool = true
//@AppStorage("uzytkownik") var uzytkownik: String = ""
//@AppStorage("uzytkownikMail") var uzytkownikMail: String = ""
//
//@AppStorage("sortowEnum") var sortowEnum: sortEnum?
//@AppStorage("sortowRosn") var sortowRosn: Bool = true
//
//@AppStorage("filtrAlkGlownyRum") var filtrAlkGlownyRum: Bool = true
//@AppStorage("filtrAlkGlownyWhiskey") var filtrAlkGlownyWhiskey: Bool = true
//@AppStorage("filtrAlkGlownyTequila") var filtrAlkGlownyTequila: Bool = true
//@AppStorage("filtrAlkGlownyBrandy") var filtrAlkGlownyBrandy: Bool = true
//@AppStorage("filtrAlkGlownyGin") var filtrAlkGlownyGin: Bool = true
//@AppStorage("filtrAlkGlownyVodka") var filtrAlkGlownyVodka: Bool = true
//@AppStorage("filtrAlkGlownyChampagne") var filtrAlkGlownyChampagne: Bool = true
//@AppStorage("filtrAlkGlownyInny") var filtrAlkGlownyInny: Bool = true
//
//@AppStorage("filtrSlodkoscNieSlodki") var filtrSlodkoscNieSlodki: Bool = true
//@AppStorage("filtrSlodkoscLekkoSlodki") var filtrSlodkoscLekkoSlodki: Bool = true
//@AppStorage("filtrSlodkoscSlodki") var filtrSlodkoscSlodki: Bool = true
//@AppStorage("filtrSlodkoscBardzoSlodki") var filtrSlodkoscBardzoSlodki: Bool = true
//
//@AppStorage("filtrMocBezalk") var filtrMocBezalk: Bool = true
//@AppStorage("filtrMocDelik") var filtrMocDelik: Bool = true
//@AppStorage("filtrMocSredni") var filtrMocSredni: Bool = true
//@AppStorage("filtrMocMocny") var filtrMocMocny: Bool = true
//
//@AppStorage("opcjonalneWymagane") var opcjonalneWymagane: Bool = true
//@AppStorage("zamiennikiDozwolone") var zamiennikiDozwolone: Bool = true
//@AppStorage("tylkoUlubione") var tylkoUlubione: Bool = true
//@AppStorage("tylkoDostepne") var tylkoDostepne: Bool = true

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
		case "oldfashioned": return .oldfashioned
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
	if let color = OSColor(named: clear) {
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
					.foregroundColor(configuration.isOn ? Color.accent : Color.secondary)
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

	// Opcja zamienników włączona
func zamiennikiOn(stan: sklStanEnum, pref: Bool, _ wylaczTrybZamiennikow: Bool) -> sklStanEnum {
	/// Jeśli
	if pref && wylaczTrybZamiennikow {
		return stan
	} else {
		if (stan == .jest) {
			return .jest
		} else {
			return .brak
		}
	}
}


	// MARK: KATEGORIA
struct Kategoria: View {
	var kat: String
	var body: some View {
		HStack {
			if kat != "" {
				HStack(alignment: .lastTextBaseline, spacing: 0) {
					Text("kat.: ")
						.font(.caption)
						.fontWeight(.light)
						.fontWidth(.condensed)

					Text("\(kat) ")
						.font(.headline)
						.fontWeight(.black)
						.fontWidth(.condensed)
				}
			}
		}
		.foregroundStyle(Color.secondary)
	}
} // KATEGORIA

	// MARK: PROC
struct Proc: View {
	var proc: Int
	var body: some View {
		HStack(alignment: .lastTextBaseline, spacing: 0) {

			Text("alk.:")
				.font(.caption)
				.fontWeight(.light)
				.fontWidth(.condensed)

			Text("\(proc)%")
				.font(.headline)
				.fontWeight(.black)
				.fontWidth(.condensed)

		}
		.foregroundColor(Color.secondary)
	}
} // PROC

	// MARK: KAL
struct Kal: View {

	let kal: Int

	var body: some View {

		HStack(alignment: .lastTextBaseline, spacing: 0) {

			Text("kCal.:")
				.font(.caption)
				.fontWeight(.light)
				.fontWidth(.condensed)

			Text("\(kal)")
				.font(.headline)
				.fontWeight(.black)
				.fontWidth(.condensed)
		}
		.foregroundColor(Color.secondary)
	}
} // KAL

	// MARK: MIARA
struct Miara: View {
	var miara: miaraEnum
	var body: some View {
		if miara != miaraEnum.brak {
			HStack(alignment: .lastTextBaseline, spacing: 0) {
				Text("miara: ")
					.font(.caption)
					.fontWeight(.light)
					.fontWidth(.condensed)

				Text("\(miara.rawValue)".lowercased())
					.font(.headline)
					.fontWeight(.black)
					.fontWidth(.condensed)
			}
			.foregroundStyle(Color.secondary)
		}
	}
} // MIARA

/*	// MARK: FILTRUJ DRINKI
func filtrujDrinki(pref: PrefClass) -> [Drink] {

	return self.drArray.filter { drink in

			// Filtrowanie po słodkości
		let filtrSlodkosci =
		(pref.nieSlodki && drink.drSlodycz == drSlodyczEnum.nieSlodki) ||
		(pref.lekkoSlodki && drink.drSlodycz == drSlodyczEnum.lekkoSlodki) ||
		(pref.slodki && drink.drSlodycz == drSlodyczEnum.slodki) ||
		(pref.bardzoSlodki && drink.drSlodycz == drSlodyczEnum.bardzoSlodki) ||
		(drink.drSlodycz == drSlodyczEnum.brakDanych)

			// Filtrowanie po głównym alkoholu
		let filtrAlkGlownego =
		(pref.alkGlownyRum && drink.drAlkGlowny.contains { $0 == .rum }) ||
		(pref.alkGlownyWhiskey && drink.drAlkGlowny.contains { $0 == .whiskey }) ||
		(pref.alkGlownyTequila && drink.drAlkGlowny.contains { $0 == .tequila }) ||
		(pref.alkGlownyBrandy && drink.drAlkGlowny.contains { $0 == .brandy }) ||
		(pref.alkGlownyGin && drink.drAlkGlowny.contains { $0 == .gin }) ||
		(pref.alkGlownyVodka && drink.drAlkGlowny.contains { $0 == .vodka }) ||
		(pref.alkGlownyChampagne && drink.drAlkGlowny.contains { $0 == .champagne }) ||
		(pref.alkGlownyInny && drink.drAlkGlowny.contains { $0 == .inny })

			// Filtrowanie po mocy alkoholu
		let filtrMocy =
		((pref.alkBezalk && drink.drMoc == drMocEnum.bezalk) ||
		 (pref.alkDelik && drink.drMoc == drMocEnum.delik) ||
		 (pref.alkSredni && drink.drMoc == drMocEnum.sredni) ||
		 (pref.alkMocny && drink.drMoc == drMocEnum.mocny)) ||
		drink.drMoc == drMocEnum.brakDanych

			// Filtrowanie po preferencjach
		let filtrPreferencji =
		(!pref.ulubione || drink.drUlubiony) &&
		(!pref.dostepne || drink.drBrakuje == 0)

			//			return filtrSlodkosci && filtrMocy && filtrAlkGlownego && filtrPreferencji
		return filtrSlodkosci && filtrMocy
	}
	}
*/
