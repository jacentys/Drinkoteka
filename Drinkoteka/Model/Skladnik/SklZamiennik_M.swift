import SwiftData
import Foundation

@Model
class SklZamiennik_M {
	@Relationship(deleteRule: .cascade) var skladnikZ: Skl_M
	@Relationship(deleteRule: .cascade) var zamiennikZ: Skl_M

	init(skladnikZ: Skl_M, zamiennikZ: Skl_M) {
		self.skladnikZ = skladnikZ
		self.zamiennikZ = zamiennikZ
	}

	var customMirror: Mirror {
		Mirror(self, children: [
			"skladnikZ": zamiennikZ,
			"zamiennikZ": zamiennikZ
		])
	}
}
