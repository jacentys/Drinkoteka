import SwiftData
import SwiftUI

/// Model SwiftData pojedynczego drinka.
/// Powiązane modele: `DrSkladnik_M` (pozycje składników) i `DrPrzepis_M` (kroki przepisu)
/// dołączone relacjami z regułą `.cascade` (usunięcie drinka kasuje jego składniki i kroki).
/// Dane wypełniane są z Supabase (`loadFromSupabase`), nie z lokalnych plików.
@Model
class Dr_M: Identifiable {
	// Klucze ustawień filtrowania w UserDefaults. Model odczytuje je bezpośrednio,
	// bo `setBrakiDrinka()` musi znać aktualne preferencje (opcjonalne/zamienniki),
	// żeby policzyć ile składników brakuje — bez przekazywania ich z widoku.
	private var opcjonalneWymaganeKey = "opcjonalneWymagane"
	private var zamiennikiDozwoloneKey = "zamiennikiDozwolone"
	private var tylkoUlubioneKey = "tylkoUlubione"
	private var tylkoDostepneKey = "tylkoDostepne"

	private var sklBrakiMinKey = "sklBrakiMin"
	private var sklBrakiMaxKey = "sklBrakiMax"

		// Lustro ustawień z UserDefaults (współdzielone z @AppStorage w widokach)
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
		
	@Attribute(.unique) var id: String
	@Attribute(.unique) var drinkID: String
	@Attribute(.unique) var drNazwa: String
	var drKat: drKatEnum
	var drZrodlo: String
	var drKolor: String
	var drFoto: String
	var drProc: Int
	var drSlodycz: drSlodyczEnum
	var drSzklo: szkloEnum
	var drUlubiony: Bool
	var drNotatka: String
	var drUwagi: String
	var drWWW: String
	var drKal: Int
	var drMoc: drMocEnum
	var drBrakuje: Int
	var drAlkGlowny: [alkGlownyEnum]
	@Relationship(deleteRule: .cascade, inverse: \DrSkladnik_M.relacjaDrink) var drSklad: [DrSkladnik_M] = []
	@Relationship(deleteRule: .cascade, inverse: \DrPrzepis_M.relacjaDrink) var drPrzepis: [DrPrzepis_M] = []

	init(
		id: String = UUID().uuidString,
		drinkID: String,
		drNazwa: String,
		drKat: drKatEnum,
		drZrodlo: String,
		drKolor: String,
		drFoto: String,
		drProc: Int,
		drSlodycz: drSlodyczEnum,
		drSzklo: szkloEnum,
		drUlubiony: Bool,
		drNotatka: String,
		drUwagi: String,
		drWWW: String = "",
		drKal: Int,
		drMoc: drMocEnum,
		drBrakuje: Int,
		drAlkGlowny: [alkGlownyEnum],
		drSklad: [DrSkladnik_M],
		drPrzepis: [DrPrzepis_M]
	) {
		self.id = id
		self.drinkID = drinkID
		self.drNazwa = drNazwa
		self.drKat = drKat
		self.drZrodlo = drZrodlo
		self.drKolor = drKolor
		self.drFoto = drFoto
		self.drProc = drProc
		self.drSlodycz = drSlodycz
		self.drSzklo = drSzklo
		self.drUlubiony = drUlubiony
		self.drNotatka = drNotatka
		self.drUwagi = drUwagi
		self.drWWW = drWWW
		self.drKal = drKal
		self.drMoc = drMoc
		self.drBrakuje = drBrakuje
		self.drAlkGlowny = drAlkGlowny
		self.drSklad = drSklad
		self.drPrzepis = drPrzepis
	}
	
		// MARK: - CZY IBA (darmowy dostęp)
	// Drinki ze źródeł "IBA..." są dostępne bez logowania (darmowy rdzeń oferty).
	var czyIBA: Bool {
		drZrodlo.hasPrefix("IBA")
	}

	// MARK: - GET COLOR
	func getKolor() -> Color {
		return strToColor(self.drKolor)
	}
	
		// MARK: - SET SKLADNIKI
	func setSkladnikiAll(_ drSkladniki: [DrSkladnik_M]) {
		self.drSklad = drSkladniki
	}
	
		// MARK: - ULUBIONY TOGGLE
	func ulubionyToggle() {
		self.drUlubiony.toggle()
	}
	
		// MARK: - SET NOTATKA
	func setNotatka(tekst: String) {
		self.drNotatka = tekst
	}
	
	
		// MARK: - SET KALORIE
	func setKalorie(kalorie: Int) {
		self.drKal = kalorie
	}
	
		// MARK: - SET ALK GŁÓWNY
	func setalkGlowny(alkGlowny: [alkGlownyEnum]) {
		self.drAlkGlowny = alkGlowny
	}
	
		// MARK: - SET MOC
	func setMoc(moc: drMocEnum) {
		self.drMoc = moc
	}
	
		// MARK: - GET SKL DIFFERENCE
	// Przelicza `drBrakuje` = ile składników drinka NIE ma użytkownik w barku.
	// Uwzględnia ustawienia: czy liczyć składniki opcjonalne i czy dopuszczać zamienniki.
	// Wywoływane po zmianie stanu składników / ustawień filtrów.
	func setBrakiDrinka() {
		var ileSkladnikow: Int = 0
		var ileNaStanie: Int = 0
		var skladnikiDrinka: [DrSkladnik_M] = []
		
			/// Jeśli opcjonalne są wymagane wtedy wszystkie składniki.
		if opcjonalneWymagane {
			skladnikiDrinka = self.drSklad
		} else { /// W przeciwnym wypadku bez opcjonalnych
			skladnikiDrinka = self.drSklad.filter { !$0.sklOpcja }
		}
			// Policz ilość składników
		ileSkladnikow = skladnikiDrinka.count
		
			/// Jeśli zamienniki są dozwolone
		if zamiennikiDozwolone {
			for skladnik in skladnikiDrinka {
				if (skladnik.skladnik.sklStan == .jest ||
						skladnik.skladnik.sklStan == .zmJest) {
					ileNaStanie += 1
				}
			}
		} else {
			for skladnik in skladnikiDrinka {
				if skladnik.skladnik.sklStan == .jest {
					ileNaStanie += 1
				}
			}
		}
		self.drBrakuje = ileSkladnikow - ileNaStanie
	}
}
