import SwiftData
import Foundation

@Model
class DrinkPrzepis_M: Identifiable {
	@Attribute(.unique) var id: String
	@Relationship var relacjaDrink: Drink_M
	var drinkID: String
	var przepNo: Int
	var przepOpis: String
	var przepOpcja: Bool
	init(
		id: String = UUID().uuidString,
		relacjaDrink: Drink_M,
		drinkID: String,
		przepNo: Int,
		przepOpis: String = "",
		przepOpcja: Bool = false
	) {
		self.id = id
		self.relacjaDrink = relacjaDrink
		self.drinkID = drinkID
		self.przepNo = przepNo
		self.przepOpis = przepOpis
		self.przepOpcja = przepOpcja
	}
}
