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
	@Relationship(deleteRule: .cascade, inverse: \SklZamiennik_M.skladnik)
	var relacjeZamiennikow: [SklZamiennik_M] = []

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
		sklWWW: String
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
	}

		// Rest of the methods remain the same...
	var zamienniki: [Skl_M] {
		relacjeZamiennikow.map { $0.zamiennik }
	}

	func addZamiennik(_ zamiennik: Skl_M) {
		guard !zamienniki.contains(where: { $0.id == zamiennik.id }) else { return }
		let nowaRelacja = SklZamiennik_M(skladnik: self, zamiennik: zamiennik)
		relacjeZamiennikow.append(nowaRelacja)
	}

	func removeZamiennik(_ zamiennik: Skl_M) {
		relacjeZamiennikow.removeAll { $0.zamiennik.id == zamiennik.id }
	}

	func clearZamienniki() {
		relacjeZamiennikow.removeAll()
	}

	func getKolor() -> Color {
		return strToColor(self.sklKolor)
	}

	func stanToggle() {
		if self.zamienniki.isEmpty {
			if self.sklStan == sklStanEnum.jest { self.sklStan = sklStanEnum.brak }
			else { self.sklStan = sklStanEnum.jest }
		}
	}

	func setOpis(_ opis: String) {
		self.sklOpis = opis
	}
}

