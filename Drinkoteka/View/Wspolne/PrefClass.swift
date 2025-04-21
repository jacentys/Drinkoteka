import SwiftData
import SwiftUI

// MARK: Preferencje listy drinków
class PrefClass: ObservableObject {
	@Environment(\.modelContext) private var modelContext

	
	@Published var sortowEnum: sortEnum
	@Published var sortowRosn: Bool
	
	@Published var alkGlownyRum = true
	@Published var alkGlownyWhiskey = true
	@Published var alkGlownyTequila = true
	@Published var alkGlownyBrandy = true
	@Published var alkGlownyGin = true
	@Published var alkGlownyVodka = true
	@Published var alkGlownyChampagne = true
	@Published var alkGlownyInny = true
	
	@Published var nieSlodki = true
	@Published var lekkoSlodki = true
	@Published var slodki = true
	@Published var bardzoSlodki = true
	
	@Published var alkBezalk = true
	@Published var alkDelik = true
	@Published var alkSredni = true
	@Published var alkMocny = true
	
	@Published var opcjonalne = true
	@Published var zamienniki = true
	@Published var ulubione = true
	@Published var dostepne = false

	@Published var maxProcentyValue: Double
	@Published var maxKalorieValue: Double
	@Published var minKalorieValue: Double
	@Published var procentyRange: ClosedRange<Double>
	@Published var kalorieRange: ClosedRange<Double>
	
	init(
		sortowEnum: sortEnum = sortEnum.nazwa,
		sortowRosn: Bool = true,
		
		alkGlownyRum: Bool = true,
		alkGlownyWhiskey: Bool = true,
		alkGlownyTequila: Bool = true,
		alkGlownyBrandy: Bool = true,
		alkGlownyGin: Bool = true,
		alkGlownyVodka: Bool = true,
		alkGlownyChampagne: Bool = true,
		alkGlownyInny: Bool = true,
		
		nieSlodki: Bool = true,
		lekkoSlodki: Bool = true,
		slodki: Bool = true,
		bardzoSlodki: Bool = true,
		
		alkBezalk: Bool = true,
		alkDelik: Bool = true,
		alkSredni: Bool = true,
		alkMocny: Bool = true,
		
		opcjonalne: Bool = false,
		zamienniki: Bool = true,
		ulubione: Bool = false,
		dostepne: Bool = true,

		maxProcentyValue: Double = 100,
		maxKalorieValue: Double = 1000,
		minKalorieValue: Double = 0,
		procentyRange: ClosedRange<Double> = 0...100,
		kalorieRange: ClosedRange<Double> = 0...1000)
	{
		self.sortowEnum = sortowEnum
		self.sortowRosn = sortowRosn
		
		self.alkGlownyRum = alkGlownyRum
		self.alkGlownyWhiskey = alkGlownyWhiskey
		self.alkGlownyTequila = alkGlownyTequila
		self.alkGlownyBrandy = alkGlownyBrandy
		self.alkGlownyGin = alkGlownyGin
		self.alkGlownyVodka = alkGlownyVodka
		self.alkGlownyChampagne = alkGlownyChampagne
		self.alkGlownyInny = alkGlownyInny
		
		self.nieSlodki = nieSlodki
		self.lekkoSlodki = lekkoSlodki
		self.slodki = slodki
		self.bardzoSlodki = bardzoSlodki
		
		self.alkBezalk = alkBezalk
		self.alkDelik = alkDelik
		self.alkSredni = alkSredni
		self.alkMocny = alkMocny
		
		self.opcjonalne = opcjonalne
		self.zamienniki = zamienniki
		self.ulubione = ulubione
		self.dostepne = dostepne

		self.maxProcentyValue = maxProcentyValue
		self.maxKalorieValue = maxKalorieValue
		self.minKalorieValue = minKalorieValue
		self.procentyRange = procentyRange
		self.kalorieRange = kalorieRange
	}
	
	// MARK: GET OPCJONALNE
	func getOpcjonalne() -> Bool {
		return self.opcjonalne
	}
	
		// MARK: SET PROC MAX
	func setProcMax(procMax: Double) {
		self.maxProcentyValue = procMax
		self.procentyRange = 0...procMax
	}

	// MARK: SET KAL MIN MAX
	func setKalorie(kalMin: Double, kalMax: Double) {
		self.maxKalorieValue = kalMax
		self.kalorieRange = kalMin...kalMax
	}

	// MARK: SET SORTOWANIE TOGGLE
	func sortowRosnToggle() {
		self.sortowRosn.toggle()
	}
}
