import SwiftData
import Foundation

@Model
class DrinkSkladnik_M: Identifiable {
	@Attribute(.unique) var id: String
	@Relationship var relacjaDrink: Drink_M
	var drinkID: String
	var skladnikID: String
	var sklNo: Int
	var sklIlosc: Double
	var sklMiara: miaraEnum
	var sklInfo: String
	var sklOpcja: Bool
	init(
		id: String = UUID().uuidString,
		relacjaDrink: Drink_M,
		drinkID: String,
		skladnikID: String,
		sklNo: Int,
		sklIlosc: Double,
		sklMiara: miaraEnum = miaraEnum.brak,
		sklInfo: String = "",
		sklOpcja: Bool = false
	) {
		self.id = id
		self.relacjaDrink = relacjaDrink
		self.drinkID = drinkID
		self.skladnikID = skladnikID
		self.sklNo = sklNo
		self.sklIlosc = sklIlosc
		self.sklMiara = sklMiara
		self.sklInfo = sklInfo
		self.sklOpcja = sklOpcja
	}
}
