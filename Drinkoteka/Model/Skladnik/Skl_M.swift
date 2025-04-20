import SwiftData
import SwiftUI

// MARK: SKLADNIKI STRUCT
class Skladnik: Identifiable {
	@Attribute(.unique) var id: String
	@Attribute(.unique) var sklID: String
	@Attribute(.unique) var sklNazwa: String
	let sklKat: sklKatEnum
	let sklProc: Int
	let sklKolor: String
	let sklFoto: String
	let sklStan: sklStanEnum
	let sklOpis: String
	let sklKal: Int
	let sklMiara: miaraEnum
	let sklWWW: String
	let sklZamArray: [String]
	init(
		id: String = UUID().uuidString,
		sklID: String,
		sklNazwa: String,
		sklKat: sklKatEnum,
		sklProc: Int,
		sklKolor: String,
		sklFoto: String,
		sklStan: sklStanEnum,
		sklOpis: String,
		sklKal: Int,
		sklMiara: miaraEnum,
		sklWWW: String,
		sklZamArray: [String]
	) {
		self.id = id
		self.sklID = sklID
		self.sklNazwa = sklNazwa
		self.sklKat = sklKat
		self.sklProc = sklProc
		self.sklKolor = sklKolor
		self.sklFoto = sklFoto
		self.sklStan = sklStan
		self.sklOpis = sklOpis
		self.sklKal = sklKal
		self.sklMiara = sklMiara
		self.sklWWW = sklWWW
		self.sklZamArray = sklZamArray
	}
	
		// MARK: STAN TOGGLE
	func stanToggle(_ stan: sklStanEnum) -> Skladnik {
		return Skladnik(
			id: id,
			sklID: sklID,
			sklNazwa: sklNazwa,
			sklKat: sklKat,
			sklProc: sklProc,
			sklKolor: sklKolor,
			sklFoto: sklFoto,
			sklStan: stan,
			sklOpis: sklOpis,
			sklKal: sklKal,
			sklMiara: sklMiara,
			sklWWW: sklWWW,
			sklZamArray: sklZamArray
		)
	}

		// MARK: GET COLOR
	func getColor() -> Color {
		return strToColor(self.sklKolor)
	}

		// MARK: SET ALL ZAMIENNIK
	func setAllZamienniki(_ zamienniki: [String]) -> Skladnik {
		return Skladnik(
			id: id,
			sklID: sklID,
			sklNazwa: sklNazwa,
			sklKat: sklKat,
			sklProc: sklProc,
			sklKolor: sklKolor,
			sklFoto: sklFoto,
			sklStan: sklStan,
			sklOpis: sklOpis,
			sklKal: sklKal,
			sklMiara: sklMiara,
			sklWWW: sklWWW,
			sklZamArray: zamienniki
		)
	}

		// MARK: ADD ZAMIENNIK
	func addZamiennik(zamID: String) -> Skladnik {
		var zamSklArrayTemp = self.sklZamArray
		zamSklArrayTemp.append(zamID)
		return Skladnik(
			id: id,
			sklID: sklID,
			sklNazwa: sklNazwa,
			sklKat: sklKat,
			sklProc: sklProc,
			sklKolor: sklKolor,
			sklFoto: sklFoto,
			sklStan: sklStan,
			sklOpis: sklOpis,
			sklKal: sklKal,
			sklMiara: sklMiara,
			sklWWW: sklWWW,
			sklZamArray: zamSklArrayTemp
		)
	}

		// MARK: SET OPIS
	func setOpis(_ opis: String) -> Skladnik {
		return Skladnik(
			id: id,
			sklID: sklID,
			sklNazwa: sklNazwa,
			sklKat: sklKat,
			sklProc: sklProc,
			sklKolor: sklKolor,
			sklFoto: sklFoto,
			sklStan: sklStan,
			sklOpis: opis,
			sklKal: sklKal,
			sklMiara: sklMiara,
			sklWWW: sklWWW,
			sklZamArray: sklZamArray
		)
	}
}
