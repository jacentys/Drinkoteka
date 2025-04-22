import SwiftUI

// MARK: SKL KATEGORIE
enum sklKatEnum: String, CaseIterable, Codable, Identifiable {
	var id: Self { self }
	case alkohol = "alkohol"
	case likiery = "likiery"
	case syropy = "syropy"
	case soki = "soki"
	case przyprawy = "przyprawy"
	case owoce = "owoce"
	case inne = "inne"

	var opis: String {
		switch self {
			case .alkohol: return "Alkohol"
			case .likiery: return "Likiery"
			case .syropy: return "Syropy"
			case .soki: return "Soki"
			case .przyprawy: return "Przyprawy"
			case .owoce: return "Owoce"
			case .inne: return "Inne"

		}
	}
}

// MARK: SKL STAN
enum sklStanEnum: String, CaseIterable, Codable {
	case jest = "jest"
	case brak = "brak"
	case zmJest = "zmJest"
	case zmBrak = "zmBrak"

	var stan: Bool {
		switch self {
			case .jest:
				return true
			case .brak:
				return false
			case .zmJest:
				return false
			case .zmBrak:
				return false
		}
	}
	var ikonka: String {
		switch self {
			case .jest:
				return "checkmark.circle.fill"
			case .brak:
				return "circle"
			case .zmJest:
				return "repeat.circle.fill"
			case .zmBrak:
				return "repeat.circle"
		}
	}
	var opis: String {
		switch self {
			case .jest:
				return "W Barku"
			case .brak:
				return "Brak"
			case .zmJest:
				return "W Barku"
			case .zmBrak:
				return "Brak"
		}
	}
	var kolor: Color {
		switch self {
			case .jest:
				return Color.orange
			case .brak:
				return Color.secondary
			case .zmJest:
				return Color.orange
			case .zmBrak:
				return Color.secondary
		}
	}
}

// MARK: DR MOC
enum drMocEnum: String, CaseIterable, Codable {
	case bezalk = "bezalk"
	case delik = "delik"
	case sredni = "sredni"
	case mocny = "mocny"
	case brakDanych = "brakDanych"

	var sort: Int {
		switch self {
			case .bezalk:
				return 0
			case .delik:
				return 1
			case .sredni:
				return 2
			case .mocny:
				return 3
			case .brakDanych:
				return 4
		}
	}
	var start: Int {
		switch self {
			case .bezalk:
				return 0
			case .delik:
				return 1
			case .sredni:
				return 13
			case .mocny:
				return 21
			case .brakDanych:
				return -1
		}
	}
	var opisLong: String {
		switch self {
			case .bezalk:
				return "Bezalkoholowe"
			case .delik:
				return "Delikatne"
			case .sredni:
				return "Średnie"
			case .mocny:
				return "Mocne"
			case .brakDanych:
				return "Brak Danych"
		}
	}
	var opisShort: String {
		switch self {
				case .bezalk:
					return "Bezalk."
				case .delik:
					return "Delik."
				case .sredni:
					return "Średni"
				case .mocny:
					return "Mocny"
				case .brakDanych:
					return "B.Danych"
		}
	}
}

// MARK: DR KAT
enum drKatEnum: String, CaseIterable, Codable {
	case koktail = "Koktail"
	case shot = "Shot"
	case brakDanych = "Brak Danych"
}

// MARK: DR SLODYCZ
enum drSlodyczEnum: String, CaseIterable, Codable  {
	case nieSlodki = "Nie Słodki"
	case lekkoSlodki = "Lekko Słodki"
	case slodki = "Słodki"
	case bardzoSlodki = "Bardzo Słodki"
	case brakDanych = "Brak Danych"

	var sort: Int {
		switch self {
			case .nieSlodki:
				return 0
			case .lekkoSlodki:
				return 1
			case .slodki:
				return 2
			case .bardzoSlodki:
				return 3
			case .brakDanych:
				return 4
		}

	}
}

// MARK: SZKLO
enum szkloEnum: String, CaseIterable, Codable {
	case collins = "collins"
	case whiskey = "whiskey"
	case oldFashioned = "oldFashioned"
	case koktailowy = "koktailowy"
	case szampan = "szampan"
	case wino = "wino"
	case margarita = "margarita"
	case kieliszek = "kieliszek"
	case inne = "inne"

	var opis: String {
		switch self {
			case .collins: return "Szklanka Collins"
			case .whiskey: return "Szklanka Whiskey"
			case .oldFashioned: return "Szklanka Old Fashioned"
			case .koktailowy: return "Kieliszek Koktailowy"
			case .szampan: return "Kielliszek do Szampana"
			case .wino: return "Kieliszek do Wina"
			case .margarita: return "Kieliszek do Margarity"
			case .kieliszek: return "Kieliszek do Wódki"
			default: return "Brak danyh"
		}
	}
	
	var foto: String {
		switch self {
			case .collins: return "szkloCollins"
			case .whiskey: return "szkloWhiskey"
			case .oldFashioned: return "szkloOldFashioned"
			case .koktailowy: return "szkloKoktailowy"
			case .szampan: return "szkloSzampan"
			case .wino: return "szkloWino"
			case .margarita: return "szkloMargarita"
			case .kieliszek: return "szkloKieliszek"
			default: return "szkloBlackglass"
		}
	}
	
	var obj: Int {
		switch self {
			case .collins: return 350
			case .whiskey: return 180
			case .oldFashioned: return 300
			case .koktailowy: return 130
			case .szampan: return 150
			case .wino: return 150
			case .margarita: return 190
			case .kieliszek: return 35
			default: return 250
		}
	}
}

// MARK: SORTOWANIE
enum sortEnum: String {
	case nazwa = "nazwa"
	case slodycz = "slodycz"
	case procenty = "procenty"
	case kcal = "kcal"
	case sklad = "sklad"
}

// MARK: MIARA
enum miaraEnum: String, CaseIterable, Codable, Identifiable {
	var id: Self { self }
	case ml = "ml"
	case gr = "gr"
	case kropla = "kropla"
	case owoc = "owoc"
	case kawalek = "kawalek"
	case polowka = "polowka"
	case cwiartka = "cwiartka"
	case plaster = "plaster"
	case kostka = "kostka"
	case listek = "listek"
	case odrobina = "odrobina"
	case szczypta = "szczypta"
	case sztuka = "sztuka"
	case dopelnienie = "dopelnienie"
	case galazka = "galazka"
	case brak = ""

	var opis: String {
		switch self {
			case .ml: return "ml."
			case .gr: return "gr."
			case .kropla: return "krople"
			case .owoc: return "owoce"
			case .kawalek: return "kawałki"
			case .polowka: return "połówki"
			case .cwiartka: return "ćwiartki"
			case .plaster: return "plastry"
			case .kostka: return "kostki"
			case .listek: return "listki"
			case .odrobina: return "odrobina"
			case .szczypta: return "szczypty"
			case .sztuka: return "sztukia"
			case .dopelnienie: return "dopełnienie"
			case .galazka: return "gałązki"
			case .brak: return "brak"
		}
	}

}

// MARK: ALK GŁÓWNY
enum alkGlownyEnum: String, CaseIterable, Codable, Identifiable {
	var id: Self { self }
	case rum = "rum"
	case whiskey = "whiskey"
	case gin = "gin"
	case tequila = "tequilamez"
	case brandy = "brandy"
	case vodka = "vodka"
	case champagne = "champagne"
	case inny = "inny"

	var opis: String {
		switch self {
			case .rum: return "Rum"
			case .whiskey: return "Whiskey"
			case .gin: return "Gin"
			case .tequila: return "Tequila / Mezcal"
			case .brandy: return "Brandy"
			case .vodka: return "Vodka"
			case .champagne: return "Champagne"
			case .inny: return "Inne"
		}
	}

}
