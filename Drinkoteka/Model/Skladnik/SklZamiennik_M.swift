import SwiftData
import Foundation

	// MARK: STRUCT SKLADNIKI ZAMIENNIKI
//@Model
class SklZamiennik_M: Identifiable {
	@Attribute(.unique) var id: String
	var skladnikID: String
	var skladnik: Skl_M
	var zamiennikID: String
	var zamienniki: [Skl_M]
	init(
		id: String = UUID().uuidString,
		skladnikID: String,
		skladnik: Skl_M,
		zamiennikID: String,
		zamienniki: [Skl_M]
	) {
		self.id = id
		self.skladnikID = skladnikID
		self.skladnik = skladnik
		self.zamiennikID = zamiennikID
		self.zamienniki = zamienniki
	}
}
