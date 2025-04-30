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
//	@Relationship(deleteRule: .nullify, inverse: \Skl_M.sklOriginal)
	var sklZamArray: [Skl_M] = []
//	@Relationship(deleteRule: .nullify, inverse: \Skl_M.sklZamArray)
//	var sklOriginal: [Skl_M] = []
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
	
		// MARK: - GET KOLOR
	func getKolor() -> Color {
		return strToColor(self.sklKolor)
	}
	
		// MARK: - STAN TOGGLE
	func stanToggle() {
		@AppStorage("zamiennikiDozwolone") var zamiennikiDozwolone: Bool = true
		if self.sklZamArray.isEmpty {
			if self.sklStan == sklStanEnum.jest { self.sklStan = sklStanEnum.brak }
			else { self.sklStan = sklStanEnum.jest }
		}
//		} else {
//			/// Jeśli są zamienniki i brak zamienników dostępnych,
//			if self.sklStan == sklStanEnum.brak || self.sklStan == sklStanEnum.zmBrak
//		}
	} // FIXME: DO ZROBIENIA PRZEJŚCIA STANÓW.

		// MARK: - SET ALL ZAMIENNIK
	func setAllZamienniki(_ zamienniki: [Skl_M]) {
		self.sklZamArray = zamienniki
	}

		// MARK: - ADD ZAMIENNIK
	func addZamiennik(_ zamiennik: Skl_M) {
		if zamiennik != self {
			self.sklZamArray.append(zamiennik)
//			self.sklOriginal?.append(self)
		}
		print("Oryginał: \(self.sklNazwa), Zam: \(zamiennik.sklNazwa)")
	}
//	func addZamiennik(_ zamiennik: Skl_M) {
//		self.sklZamArray.append(zamiennik)
//	}
	
	// MARK: - DEL ZAMIENNIK
	func delZamiennik(_ zamiennik: Skl_M) {
		self.sklZamArray.removeAll { $0.id == zamiennik.id }
	}

		// MARK: - SET OPIS
	func setOpis(_ opis: String) {
		self.sklOpis = opis
	}
}
