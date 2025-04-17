import SwiftData
import SwiftUI

// MARK: DRINK STRUCT
@Model
class Drink: Identifiable {
	var id: String
	var drNazwa: String
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
//	var drSklad: [DrinkSkladnik]
//	var drPrzepis: [DrinkiPrzepisy]
	var drKalorie: Int
	var drMoc: drMocEnum
	var drBrakuje: Int
	var drAlkGlowny: [alkGlownyEnum]

	init(
		id: String,
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
//		drSklad: [DrinkSkladnik],
//		drPrzepis: [DrinkiPrzepisy],
		drKalorie: Int,
		drMoc: drMocEnum,
		drBrakuje: Int,
		drAlkGlowny: [alkGlownyEnum]
	) {
		self.id = id
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
//		self.drSklad = drSklad
//		self.drPrzepis = drPrzepis
		self.drKalorie = drKalorie
		self.drMoc = drMoc
		self.drBrakuje = drBrakuje
		self.drAlkGlowny = drAlkGlowny
	}

		// MARK: SET SKLADNIKI
//	func setSkladnikiAll(_ drSkladniki: [DrinkSkladnik]) -> Drink {
//		return Drink(
//			id: id,
//			drNazwa: drNazwa,
//			drKat: drKat,
//			drZrodlo: drZrodlo,
//			drKolor: drKolor,
//			drFoto: drFoto,
//			drProc: drProc,
//			drSlodycz: drSlodycz,
//			drSzklo: drSzklo,
//			drUlubiony: drUlubiony,
//			drNotatka: drNotatka,
//			drUwagi: drUwagi,
//			drWWW: drWWW,
//			drSklad: drSkladniki,
//			drPrzepis: drPrzepis,
//			drKalorie: drKalorie,
//			drMoc: drMoc,
//			drBrakuje: drBrakuje,
//			drAlkGlowny: drAlkGlowny
//		)
//	}

//	// MARK: GET COLOR
//	func getKolor () -> Color {
//		return stringToColor(self.drKolor)
//	}

	// MARK: ULUBIONY TOGGLE
	func ulubionyToggle() -> Drink {
		return Drink(
			id: id,
			drNazwa: drNazwa,
			drKat: drKat,
			drZrodlo: drZrodlo,
			drKolor: drKolor,
			drFoto: drFoto,
			drProc: drProc,
			drSlodycz: drSlodycz,
			drSzklo: drSzklo,
			drUlubiony: !drUlubiony,
			drNotatka: drNotatka,
			drUwagi: drUwagi,
			drWWW: drWWW,
//			drSklad: drSklad,
//			drPrzepis: drPrzepis,
			drKalorie: drKalorie,
			drMoc: drMoc,
			drBrakuje: drBrakuje,
			drAlkGlowny: drAlkGlowny
		)
	}

	// MARK: SET NOTATKA
	func setNotatka(tekst: String) -> Drink {
		return Drink(
			id: id,
			drNazwa: drNazwa,
			drKat: drKat,
			drZrodlo: drZrodlo,
			drKolor: drKolor,
			drFoto: drFoto,
			drProc: drProc,
			drSlodycz: drSlodycz,
			drSzklo: drSzklo,
			drUlubiony: drUlubiony,
			drNotatka: tekst,
			drUwagi: drUwagi,
			drWWW: drWWW,
//			drSklad: drSklad,
//			drPrzepis: drPrzepis,
			drKalorie: drKalorie,
			drMoc: drMoc,
			drBrakuje: drBrakuje,
			drAlkGlowny: drAlkGlowny
		)
	}

	// MARK: SET MOC
	func setMoc() -> Drink {

		var moc: drMocEnum = drMocEnum.brakDanych

		if (self.drProc == 0) { moc = drMocEnum.bezalk }
		if (self.drProc > 0 && self.drProc < 13) { moc = drMocEnum.delik }
		if (self.drProc > 12 && self.drProc < 21) { moc = drMocEnum.sredni }
		if (self.drProc > 20) { moc = drMocEnum.mocny }

		return Drink(
			id: id,
			drNazwa: drNazwa,
			drKat: drKat,
			drZrodlo: drZrodlo,
			drKolor: drKolor,
			drFoto: drFoto,
			drProc: drProc,
			drSlodycz: drSlodycz,
			drSzklo: drSzklo,
			drUlubiony: drUlubiony,
			drNotatka: drNotatka,
			drUwagi: drUwagi,
			drWWW: drWWW,
//			drSklad: drSklad,
//			drPrzepis: drPrzepis,
			drKalorie: drKalorie,
			drMoc: moc,
			drBrakuje: drBrakuje,
			drAlkGlowny: drAlkGlowny
		)
	}

	// MARK: SET BRAKUJE
	func setBrakuje(brak: Int) -> Drink {
		return Drink(
			id: id,
			drNazwa: drNazwa,
			drKat: drKat,
			drZrodlo: drZrodlo,
			drKolor: drKolor,
			drFoto: drFoto,
			drProc: drProc,
			drSlodycz: drSlodycz,
			drSzklo: drSzklo,
			drUlubiony: drUlubiony,
			drNotatka: drNotatka,
			drUwagi: drUwagi,
			drWWW: drWWW,
//			drSklad: drSklad,
//			drPrzepis: drPrzepis,
			drKalorie: drKalorie,
			drMoc: drMoc,
			drBrakuje: brak,
			drAlkGlowny: drAlkGlowny
		)
	}

	// MARK: SET KALORIE
	func setKalorie(kalorie: Int) -> Drink {
		return Drink(
			id: id,
			drNazwa: drNazwa,
			drKat: drKat,
			drZrodlo: drZrodlo,
			drKolor: drKolor,
			drFoto: drFoto,
			drProc: drProc,
			drSlodycz: drSlodycz,
			drSzklo: drSzklo,
			drUlubiony: drUlubiony,
			drNotatka: drNotatka,
			drUwagi: drUwagi,
			drWWW: drWWW,
//			drSklad: drSklad,
//			drPrzepis: drPrzepis,
			drKalorie: kalorie,
			drMoc: drMoc,
			drBrakuje: drBrakuje,
			drAlkGlowny: drAlkGlowny
		)
	}

		// MARK: SET ALK GŁÓWNY
	func setalkGlowny(alkGlowny: [alkGlownyEnum]) -> Drink {
		return Drink(
			id: id,
			drNazwa: drNazwa,
			drKat: drKat,
			drZrodlo: drZrodlo,
			drKolor: drKolor,
			drFoto: drFoto,
			drProc: drProc,
			drSlodycz: drSlodycz,
			drSzklo: drSzklo,
			drUlubiony: drUlubiony,
			drNotatka: drNotatka,
			drUwagi: drUwagi,
			drWWW: drWWW,
//			drSklad: drSklad,
//			drPrzepis: drPrzepis,
			drKalorie: drKalorie,
			drMoc: drMoc,
			drBrakuje: drBrakuje,
			drAlkGlowny: alkGlowny
		)
	}


//	func getSilaDrinka() -> String {
//		return self.drMoc.opisShort + " (" + String(self.drProc) + "%) "  + String(self.drKalorie) + " kCal"
//	}
	
}
