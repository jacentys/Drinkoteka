import SwiftData
import Foundation

@Model
class DrSkladnik_M: Identifiable {
	@Attribute(.unique) var id: String
	@Relationship var relacjaDrink: Dr_M
//	var drinkID: String
	@Relationship var skladnik: Skl_M
//	var skladnikID: String
	var sklNo: Int
	var sklIlosc: Double
	var sklMiara: miaraEnum
	var sklInfo: String
	var sklOpcja: Bool
	init(
		id: String = UUID().uuidString,
		relacjaDrink: Dr_M,
//		drinkID: String,
		skladnik: Skl_M,
//		skladnikID: String,
		sklNo: Int,
		sklIlosc: Double,
		sklMiara: miaraEnum = miaraEnum.brak,
		sklInfo: String = "",
		sklOpcja: Bool = false
	) {
		self.id = id
		self.relacjaDrink = relacjaDrink
//		self.drinkID = drinkID
		self.skladnik = skladnik
//		self.skladnikID = skladnikID
		self.sklNo = sklNo
		self.sklIlosc = sklIlosc
		self.sklMiara = sklMiara
		self.sklInfo = sklInfo
		self.sklOpcja = sklOpcja
	}
}
