import SwiftData
import Foundation

	// MARK: STRUCT SKLADNIKI ZAMIENNIKI
@Model
class SklZamiennik_M: Identifiable {
	@Attribute(.unique) var id: String
	var skladnikID: String
	var skladnik: Skl_M
	var zamiennikID: String
	var zamiennik: Skl_M
	init(
		id: String = UUID().uuidString,
		skladnikID: String,
		skladnik: Skl_M,
		zamiennikID: String,
		zamiennik: Skl_M
	) {
		self.id = id
		self.skladnik = skladnik
		self.skladnikID = skladnikID
		self.zamiennik = zamiennik
		self.zamiennikID = zamiennikID
	}
}
