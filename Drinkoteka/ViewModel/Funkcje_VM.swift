import CryptoKit
import SwiftData
import SwiftUI

let key = SymmetricKey(size: .bits256)

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
typealias PlatformColor = UIColor
#elseif os(macOS)
import AppKit
typealias PlatformColor = NSColor
#endif

private var opcjonalneWymaganeKey = "opcjonalneWymagane"
private var zamiennikiDozwoloneKey = "zamiennikiDozwolone"
private var tylkoUlubioneKey = "tylkoUlubione"
private var tylkoDostepneKey = "tylkoDostepne"

private var sklBrakiMinKey = "sklBrakiMin"
private var sklBrakiMaxKey = "sklBrakiMax"

	// Pobieranie wartości z UserDefaults
var opcjonalneWymagane: Bool {
	get {
		return UserDefaults.standard.bool(forKey: opcjonalneWymaganeKey)
	}
	set {
		UserDefaults.standard.set(newValue, forKey: opcjonalneWymaganeKey)
	}
}
var zamiennikiDozwolone: Bool {
	get {
		return UserDefaults.standard.bool(forKey: zamiennikiDozwoloneKey)
	}
	set {
		UserDefaults.standard.set(newValue, forKey: zamiennikiDozwoloneKey)
	}
}
var tylkoUlubione: Bool {
	get {
		return UserDefaults.standard.bool(forKey: tylkoUlubioneKey)
	}
	set {
		UserDefaults.standard.set(newValue, forKey: tylkoUlubioneKey)
	}
}
var tylkoDostepne: Bool {
	get {
		return UserDefaults.standard.bool(forKey: tylkoDostepneKey)
	}
	set {
		UserDefaults.standard.set(newValue, forKey: tylkoDostepneKey)
	}
}

var sklBrakiMin: Int {
	get {
		return UserDefaults.standard.integer(forKey: sklBrakiMinKey)
	}
	set {
		UserDefaults.standard.set(newValue, forKey: sklBrakiMinKey)
	}
}
var sklBrakiMax: Int {
	get {
		return UserDefaults.standard.integer(forKey: sklBrakiMaxKey)
	}
	set {
		UserDefaults.standard.set(newValue, forKey: sklBrakiMaxKey)
	}
}

	// MARK: - CLEARSTR
func clearStr(_ tekst: String) -> String {
	let trimmed = tekst.trimmingCharacters(in: .punctuationCharacters.union(.whitespacesAndNewlines)).lowercased()
		// Usuwanie znaków diakrytycznych (np. ą -> a, ó -> o)
	let bezDiakrytycznych = trimmed.folding(options: .diacriticInsensitive, locale: .current)
		// Usuwanie wszystkich znaków innych niż małe litery a-z i cyfry 0-9
	let clear = bezDiakrytycznych.filter { $0.isLetter || $0.isNumber }
	return clear.replacingOccurrences(of: "ł", with: "l")
}

	// MARK: - STRING -> ENUM KAT DRINKA
func strToDrKatEnum(_ tekst: String) -> drKatEnum {
	let clear = clearStr(tekst)
	switch clear {
		case "koktail": return .koktail
		case "shot": return .shot
		default: return .brakDanych
	}
}

	// MARK: - STRING -> ENUM SLODYCZ
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

	// MARK: - STRING -> ENUM SZKLO
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

	// MARK: - INT -> MOC
func strToDrMoc(_ procenty: Int) -> drMocEnum {
	if (procenty == 0) {return .bezalk}
	if (procenty > 0 && procenty < drMocEnum.sredni.start) { return .delik}
	if (procenty >= drMocEnum.sredni.start && procenty < drMocEnum.mocny.start) { return .sredni}
	if (procenty >= drMocEnum.mocny.start) { return .mocny }
	return .brakDanych
}

	// MARK: - STRING -> MOC
func valToDrMoc(_ tekst: String) -> drMocEnum {
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

	// MARK: - STRING -> ENUM SKŁADNIKA
func strToSklKatEnum(_ tekst: String) -> sklKatEnum {
	let clear = clearStr(tekst)
	guard let kategoria = sklKatEnum(rawValue: clear) else {
		print("strToSklKatEnum niepoprawne dane: \(tekst)")
		return sklKatEnum.inne
	}
	return kategoria
}

	// MARK: - STRING -> ENUM STAN
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
	// MARK: - STRING -> ENUM MIARA
func strToSklMiaraEnum(_ tekst: String) -> miaraEnum {
	let clear = clearStr(tekst)
	for jednostka in miaraEnum.allCases {
		if String(describing: jednostka).trimmingCharacters(in: .punctuationCharacters.union(.whitespacesAndNewlines)).lowercased() == clear {
			return jednostka
		}
	}
	return .brak
}

	// MARK: - STRING -> BOOL
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

	// MARK: - STRING -> COLOR
func strToColor(_ tekst: String) -> Color {
	let clear = clearStr(tekst)
	if let color = OSColor(named: clear) {
		return Color(color)
	}
	return Color.white
}

	// MARK: - STRING -> DOUBLE
func stringToDouble(_ tekst: String) -> Double {
	if let numer = Double(tekst.trimmingCharacters(in: .whitespacesAndNewlines)) {
		return numer
	}
	return 0.0
}

	// MARK: - STRING -> INT
func stringToInt(_ tekst: String) -> Int {
	if let numer = Int(tekst.trimmingCharacters(in: .whitespacesAndNewlines)) {
		return numer
	}
	return 0
}

	// MARK: - IOS CHECKBOX
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

	// MARK: - ODMIANA DRINKÓW
func drOdm(_ ilosc: Int) -> String {
	if ilosc < 1 { return "brak drinków" }
	if ilosc == 1 { return "jeden drink" }
	else if (ilosc > 1 && ilosc < 5) { return "\(ilosc) drinki" }
	else { return "\(ilosc) drinków" }
}

	// MARK: - ODMIANA SKŁADNIKÓW
func sklOdmiana(_ ilosc: Int) -> String {
	if ilosc == 0 { return "Masz wszystkie skł." }
	else { return "Brak \(ilosc) skł." }
}

	// MARK: - ODMIANA MIAR
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

	// MARK: - FORMATOWANIE CYFR
func formatNumber(_ liczba: Double) -> String {
	if liczba == 0 {
		return "Pusty"
	} else if liczba.truncatingRemainder(dividingBy: 1) == 0 {
		return String(Int(liczba)) // np. 5.0 → "5"
	} else {
		return String(format: "%.1f", liczba) // np. 5.3 → "5.3"
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
}

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
}

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
}

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
}

	// MARK: - SET WSZYSTKIE BRAKI
func setAllBraki(modelContext: ModelContext) {
//	print("Start setWszystkieBraki")
		// Tworzymy FetchDescriptor dla typu Dr_M
	let fetchDescriptor = FetchDescriptor<Dr_M>()
	
	do {
			// Pobieramy wszystkie obiekty Dr_M za pomocą FetchDescriptor
		let drinks: [Dr_M] = try modelContext.fetch(fetchDescriptor)
		
			// Iterujemy przez drinki i ustawiamy brak
		for drink in drinks {
			drink.setBrakiDrinka() // Ta metoda modyfikuje drinka
		}
		
			// Obliczamy brakMin i brakMax
		if let minValue = drinks.map({ $0.drBrakuje }).min() {
			sklBrakiMin = minValue
		}
		if let maxValue = drinks.map({ $0.drBrakuje }).max() {
			sklBrakiMax = maxValue
		}
		
			// Zapisujemy zmiany do modelContext
		try modelContext.save()
		
//		print("Koniec setWszystkieBraki")
	} catch {
		print("Błąd podczas pobierania danych lub zapisu do bazy: \(error)")
	}
}

	// MARK: - OBLICZ KALORIE
func obliczKalorie(_ drink: Dr_M) -> Int {
	let zaokraglenie = 5.0
	var kalorie: Double = 0

	for drSkladnik in drink.drSklad {
		if ( drSkladnik.skladnik.sklMiara == miaraEnum.ml ||
			  drSkladnik.skladnik.sklMiara == miaraEnum.gr ) {
			let kal = Double(drSkladnik.skladnik.sklKal) * drSkladnik.sklIlosc * 0.01
			kalorie += kal
		}
	}
	return Int((kalorie / zaokraglenie).rounded() * zaokraglenie)
}

	// MARK: - SET ALL KALORIE
func setAllDrinkKalorie(modelContext: ModelContext) {
//	print("Start setWszystkieKalorie")

		// Tworzymy FetchDescriptor dla typu Dr_M
	let fetchDescriptor = FetchDescriptor<Dr_M>()
	
	do {
			// Pobieramy wszystkie obiekty Dr_M za pomocą FetchDescriptor
		let drinks: [Dr_M] = try modelContext.fetch(fetchDescriptor)
		
			// Iterujemy przez drinki i ustawiamy brak
		for drink in drinks {
			if !drink.drSklad.isEmpty {
				drink.setKalorie(kalorie: obliczKalorie(drink))
			}
		}
			// Zapisujemy zmiany do modelContext
		try modelContext.save()
		
//		print("Koniec setWszystkieKalorie")
	} catch {
		print("Błąd podczas pobierania danych lub zapisu do bazy: \(error)")
	}
}

	// MARK: - SET ALL PROCENTY
func setAllDrinkProcenty(modelContext: ModelContext) {
//	print("Start setAllDrinkProcenty")
	var procenty: Double = 0
	var objetosc: Double = 0
	
		// Tworzymy FetchDescriptor dla typu Dr_M
	let fetchDescriptor = FetchDescriptor<Dr_M>()
	
	do {
			// Pobieramy wszystkie obiekty Dr_M za pomocą FetchDescriptor
		let drinks: [Dr_M] = try modelContext.fetch(fetchDescriptor)
		
			// Iterujemy przez drinki i ustawiamy brak
		for drink in drinks {
			if !drink.drSklad.isEmpty {
				for drSkladnik in drink.drSklad {
					if drSkladnik.sklMiara == miaraEnum.ml {
						objetosc += drSkladnik.sklIlosc
						procenty += Double(drSkladnik.skladnik.sklProc) * drSkladnik.sklIlosc
					}
				}
			}
			let objCalkowita = ((Double(drink.drSzklo.obj) - objetosc) * 0.25) + objetosc
			let procentyCalkowite = (procenty / objCalkowita)
			let objInt = Int(objCalkowita)
			let procInt = Int(procentyCalkowite)
//			print("\(drink.drNazwa), old: \(drink.drProc), new: \(procInt), obj. \(objInt)")
			drink.drProc = procInt
				// Zapisujemy zmiany do modelContext
			try modelContext.save()
		}
//		print("Koniec setAllDrinkProcenty")
	} catch {
		print("Błąd podczas pobierania danych lub zapisu do bazy: \(error)")
	}
}

	// MARK: - GET SKL -> ZAMIENNIKI
func getZamienniki(skladnik: Skl_M) -> [Skl_M] {
	for zam in skladnik.zamienniki {
		print(zam.sklNazwa)
	}
	return skladnik.zamienniki
}

	// MARK: - ENCODE JSON
func encodeJSON<T: Codable>(object: T) -> String? {
	let encoder = JSONEncoder()
	encoder.outputFormatting = .prettyPrinted // Dodanie formatowania z wcięciami

	do {
		let jsonData = try encoder.encode(object)

			// Zamiana danych na czytelny String
		if let jsonString = String(data: jsonData, encoding: .utf8) {
			return jsonString
		} else {
			print("Błąd konwersji danych na tekst")
			return nil
		}
	} catch {
		print("Błąd kodowania: \(error)")
		return nil
	}
}

	// MARK: - DECODE JSON
func decodeJSON<T: Codable>(jsonData: Data, type: T.Type) -> T? {
	let decoder = JSONDecoder()

	do {
		let object = try decoder.decode(T.self, from: jsonData)
		return object
	} catch {
		print("Błąd dekodowania: \(error)")
		return nil
	}
}

	// MARK: - ENCRYPT AES DATA
func encryptData(data: Data, key: SymmetricKey) -> Data? {
	do {
			// AES-GCM zapewnia zarówno szyfrowanie, jak i uwierzytelnianie danych
		let sealedBox = try AES.GCM.seal(data, using: key)

			// Zwracamy zaszyfrowane dane (w tym IV i tag autentykacji)
		return sealedBox.combined
	} catch {
		print("Błąd szyfrowania: \(error)")
		return nil
	}
}

	// MARK: - DECRYPT AES DATA
func decryptData(encryptedData: Data, key: SymmetricKey) -> Data? {
	do {
			// Zdeszyfrowanie danych przy użyciu AES-GCM
		let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
		let decryptedData = try AES.GCM.open(sealedBox, using: key)

		return decryptedData
	} catch {
		print("Błąd deszyfrowania: \(error)")
		return nil
	}
}

	// MARK: - SET STAN
func setStan(_ skladnik: Skl_M) -> sklStanEnum {
	let stan = skladnik.sklIkonaZ
	let zam = skladnik.zamienniki
	var stanPoZmianie: sklStanEnum = skladnik.sklIkonaZ

//	print("Na starcie: stan", stanPoZmianie, "zam: ", zam.count)

	if zam.isEmpty {
		if stan == .jest { stanPoZmianie = .brak
		} else { stanPoZmianie = .jest }
	} else {
		let jestZamiennik = zam.contains { $0.sklIkonaZ == .jest }
		if stan == .jest {
			if zamiennikiDozwolone && jestZamiennik { stanPoZmianie = .zmJest }
			if zamiennikiDozwolone && !jestZamiennik { stanPoZmianie = .zmBrak }
			if !zamiennikiDozwolone { stanPoZmianie = .brak }
		} else {
			stanPoZmianie = .jest
		}
	}
	return stanPoZmianie
}

	// MARK: - SET STAN WYBRANE
func zmianaStanuSkladnika(context: ModelContext, zamiennik: Skl_M) {
	do {
			// Fetch all Skl_M and filter in memory
		let wszystkieSkladniki = try context.fetch(FetchDescriptor<Skl_M>())
		let skladniki = wszystkieSkladniki.filter { skladnik in
			skladnik.relacjeZamiennikow.contains { $0.zamiennikZ == zamiennik }
		}
		
			// Fetch all Dr_M and filter in memory
		let wszystkieDrinki = try context.fetch(FetchDescriptor<Dr_M>())
		let drinki = wszystkieDrinki.filter { drink in
			drink.drSklad.contains { $0.skladnik == zamiennik }
		}
		
		print("=========== Powiązane składniki: ")
		for skl in skladniki {
			if skl != zamiennik {
				skl.sklIkonaZ = setStan(skl)
				skl.sklIkonaB = setStan(skl)
				print(skl.sklNazwa)
			}
		}
		
		print("=========== Powiązane drinki: ")
		for dr in drinki {
			print(dr.drNazwa)
		}
	} catch {
		print("Błąd w funkcji zmianaStanuSkladnika: ", error.localizedDescription)
	}
}
