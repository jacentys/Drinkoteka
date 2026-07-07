import SwiftData
import Foundation

/// Relacja pośrednia: łączy składnik (`skladnikZ`) z jego zamiennikiem (`zamiennikZ`).
/// Pozwala modelować zamienniki jako graf między obiektami `Skl_M`.
@Model
class SklZamiennik_M {
	@Relationship(deleteRule: .cascade) var skladnikZ: Skl_M
	@Relationship(deleteRule: .cascade) var zamiennikZ: Skl_M

	init(skladnikZ: Skl_M, zamiennikZ: Skl_M) {
		self.skladnikZ = skladnikZ
		self.zamiennikZ = zamiennikZ
	}
}
