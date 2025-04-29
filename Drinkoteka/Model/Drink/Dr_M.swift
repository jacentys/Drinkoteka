import SwiftData
import SwiftUI

@Model
class Dr_M: Identifiable {
	@Attribute(.unique) var id: String
	@Attribute(.unique) var drinkID: String
	@Attribute(.unique) var drNazwa: String
	var drKat: drKatEnum
	var drZrodlo: String
	var drKolor: String
	var drFoto: String
	var drProc: Int
	var drSlodycz: drSlodyczEnum
	var drSzklo: szkloEnum
	var drUlubiony: Bool
	var drNotatka: String
	var drUwagi: String
	var drWWW: String
	var drKal: Int
	var drMoc: drMocEnum
	var drBrakuje: Int
	var drAlkGlowny: [alkGlownyEnum]
	@Relationship(deleteRule: .cascade, inverse: \DrSkladnik_M.relacjaDrink) var drSklad: [DrSkladnik_M] = []
	@Relationship(deleteRule: .cascade, inverse: \DrPrzepis_M.relacjaDrink) var drPrzepis: [DrPrzepis_M] = []

	init(
		id: String = UUID().uuidString,
		drinkID: String,
		drNazwa: String,
		drKat: drKatEnum,
		drZrodlo: String,
		drKolor: String,
		drFoto: String,
		drProc: Int,
		drSlodycz: drSlodyczEnum,
		drSzklo: szkloEnum,
		drUlubiony: Bool,
		drNotatka: String,
		drUwagi: String,
		drWWW: String = "",
		drKal: Int,
		drMoc: drMocEnum,
		drBrakuje: Int,
		drAlkGlowny: [alkGlownyEnum],
		drSklad: [DrSkladnik_M],
		drPrzepis: [DrPrzepis_M]
	) {
		self.id = id
		self.drinkID = drinkID
		self.drNazwa = drNazwa
		self.drKat = drKat
		self.drZrodlo = drZrodlo
		self.drKolor = drKolor
		self.drFoto = drFoto
		self.drProc = drProc
		self.drSlodycz = drSlodycz
		self.drSzklo = drSzklo
		self.drUlubiony = drUlubiony
		self.drNotatka = drNotatka
		self.drUwagi = drUwagi
		self.drWWW = drWWW
		self.drKal = drKal
		self.drMoc = drMoc
		self.drBrakuje = drBrakuje
		self.drAlkGlowny = drAlkGlowny
		self.drSklad = drSklad
		self.drPrzepis = drPrzepis
	}
	
		// MARK: - GET COLOR
	func getKolor() -> Color {
		return strToColor(self.drKolor)
	}
	
		// MARK: - SET SKLADNIKI
	func setSkladnikiAll(_ drSkladniki: [DrSkladnik_M]) {
		self.drSklad = drSkladniki
	}
	
		// MARK: - ULUBIONY TOGGLE
	func ulubionyToggle() {
		self.drUlubiony.toggle()
	}
	
		// MARK: - SET NOTATKA
	func setNotatka(tekst: String) {
		self.drNotatka = tekst
	}
	
		// MARK: - SET BRAKUJE
	func setBrakuje(brak: Int) {
		self.drBrakuje = brak
	}
	
		// MARK: - SET KALORIE
	func setKalorie(kalorie: Int) {
		self.drKal = kalorie
	}
	
		// MARK: - SET ALK GŁÓWNY
	func setalkGlowny(alkGlowny: [alkGlownyEnum]) {
		self.drAlkGlowny = alkGlowny
	}
	
		// MARK: - SET MOC
	func setMoc(moc: drMocEnum) {
		self.drMoc = moc
	}
}
