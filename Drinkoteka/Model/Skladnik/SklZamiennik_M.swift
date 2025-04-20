import SwiftData
import Foundation

	// MARK: STRUCT SKLADNIKI ZAMIENNIKI
@Model
class SklZamiennik_M: Identifiable {
	@Attribute(.unique) var id: String
	var skladnikID: String
	var zamiennikID: String
	init(
		id: String = UUID().uuidString,
		skladnikID: String,
		zamiennikID: String
	) {
		self.id = id
		self.skladnikID = skladnikID
		self.zamiennikID = zamiennikID
	}
}
