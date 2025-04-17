import SwiftData
import Foundation

	// MARK: STRUCT SKLADNIKI ZAMIENNIKI
@Model
class SklZamiennik: Identifiable {
	var skladnikID: String
	var zamiennikID: String
	init(
		skladnikID: String,
		zamiennikID: String
	) {
		self.skladnikID = skladnikID
		self.zamiennikID = zamiennikID
	}
}
