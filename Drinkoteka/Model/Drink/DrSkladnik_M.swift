import SwiftData
import Foundation

@Model
class DrSkladnik_M: Identifiable {
	@Attribute(.unique) var id: String
	@Relationship var relacjaDrink: Dr_M
	@Relationship var skladnik: Skl_M
	var sklNo: Int
	var sklIlosc: Double
	var sklMiara: miaraEnum
	var sklInfo: String
	var sklOpcja: Bool
	init(
		id: String = UUID().uuidString,
		relacjaDrink: Dr_M,
		skladnik: Skl_M,
		sklNo: Int,
		sklIlosc: Double,
		sklMiara: miaraEnum = miaraEnum.brak,
		sklInfo: String = "",
		sklOpcja: Bool = false
	) {
		self.id = id
		self.relacjaDrink = relacjaDrink
		self.skladnik = skladnik
		self.sklNo = sklNo
		self.sklIlosc = sklIlosc
		self.sklMiara = sklMiara
		self.sklInfo = sklInfo
		self.sklOpcja = sklOpcja
	}
}
