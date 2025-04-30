import SwiftData
import Foundation

@Model
class SklZamiennik_M {
	@Relationship(deleteRule: .cascade) var skladnik: Skl_M
	@Relationship(deleteRule: .cascade) var zamiennik: Skl_M

	init(skladnik: Skl_M, zamiennik: Skl_M) {
		self.skladnik = skladnik
		self.zamiennik = zamiennik
	}
}
