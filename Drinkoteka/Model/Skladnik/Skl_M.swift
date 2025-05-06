import SwiftData
import SwiftUI

@Model
class Skl_M: Identifiable, ObservableObject {
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
	@Relationship(deleteRule: .cascade, inverse: \SklZamiennik_M.skladnikZ)
	var relacjeZamiennikow: [SklZamiennik_M] = []
//	@Relationship(deleteRule: .nullify, inverse: \SklZamiennik_M.zamiennikZ)
//	var relacjeSkladnikow: [SklZamiennik_M] = []

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

	var customMirror: Mirror {
		Mirror(self, children: [
			"id": id,
			"sklID": sklID,
			"sklNazwa": sklNazwa,
			"sklKat": sklKat,
			"sklProc": sklProc,
			"sklKolor": sklKolor,
			"sklFoto": sklFoto,
			"sklStan": sklStan,
			"sklOpis": sklOpis,
			"sklKal": sklKal,
			"sklMiara": sklMiara,
			"sklWWW": sklWWW
		])
	}

	var zamienniki: [Skl_M] {
		relacjeZamiennikow.map { $0.zamiennikZ }
	}

	func addZamiennik(_ zamiennik: Skl_M) {
		guard !zamienniki.contains(where: { $0.id == zamiennik.id }) else { return }
		let nowaRelacja = SklZamiennik_M(skladnikZ: self, zamiennikZ: zamiennik)
		relacjeZamiennikow.append(nowaRelacja)
	}

	func removeZamiennik(_ zamiennik: Skl_M) {
		relacjeZamiennikow.removeAll { $0.zamiennikZ.id == zamiennik.id }
	}

	func clearZamienniki() {
		relacjeZamiennikow.removeAll()
	}

	func getKolor() -> Color {
		return strToColor(self.sklKolor)
	}

	func stanToggle() {
		if self.sklStan != .jest {
			self.sklStan = .jest
			return
		} else {
			if self.zamienniki.isEmpty {
				self.sklStan = .brak
			} else {
				if ( self.zamienniki.contains { $0.sklStan == .jest } ) {
					self.sklStan = .zmJest
				} else {
					self.sklStan = .zmBrak
				}
			}
		}
	}

	func updateSklStan(_ newStan: sklStanEnum) {
		objectWillChange.send() // Notify SwiftUI of changes
		sklStan = newStan
	}

	func setOpis(_ opis: String) {
		self.sklOpis = opis
	}
}

