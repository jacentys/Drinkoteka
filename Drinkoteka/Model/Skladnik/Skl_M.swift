import SwiftData
import SwiftUI

@Model
class Skl_M: Identifiable {
	@Attribute(.unique) var id: String
	@Attribute(.unique) var sklID: String
	@Attribute(.unique) var sklNazwa: String
	var sklKat: sklKatEnum
	var sklProc: Int
	var sklKolor: String
	var sklFoto: String
	var sklStan: sklStanEnum
	var sklOpis: String
	var sklKal: Int
	var sklMiara: miaraEnum
	var sklWWW: String
	@Relationship(deleteRule: .nullify)
	var sklZamArray: [Skl_M] = []
	@Relationship(deleteRule: .nullify, inverse: \Skl_M.sklZamArray)
	var Original: Skl_M?
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
		sklZamArray: [Skl_M]
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
	
		// MARK: GET COLOR
	func getKolor() -> Color {
		return strToColor(self.sklKolor)
	}
	
		// MARK: STAN TOGGLE
	func stanToggle(_ stan: sklStanEnum) -> Skl_M {
		return Skl_M(
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

		// MARK: SET ALL ZAMIENNIK
	func setAllZamienniki(_ zamienniki: [Skl_M]) -> Skl_M {
		return Skl_M(
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
	func addZamiennik(zamID: Skl_M) -> Skl_M {
		var zamSklArrayTemp = self.sklZamArray
		zamSklArrayTemp.append(zamID)
		return Skl_M(
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
	func setOpis(_ opis: String) -> Skl_M {
		return Skl_M(
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
