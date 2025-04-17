import SwiftData
import Foundation

// MARK: DRINKI PRZEPISY
@Model
class DrinkPrzepis: Identifiable {
	var id: String
	var drinkID: String
	var przepNo: Int
	var przepOpis: String
	var przepOpcja: Bool
	init(
		id: String,
		drinkID: String,
		przepNo: Int,
		przepOpis: String = "",
		przepOpcja: Bool = false
	) {
		self.id = id
		self.drinkID = drinkID
		self.przepNo = przepNo
		self.przepOpis = przepOpis
		self.przepOpcja = przepOpcja
	}
}
