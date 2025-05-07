import SwiftUI

class PrefClass_VM: ObservableObject {
	@AppStorage("zalogowany") var zalogowany: Bool = false
	@AppStorage("uzytkownik") var uzytkownik: String = ""
	@AppStorage("uzytkownikMail") var uzytkownikMail: String = ""

	@AppStorage("sortowEnum") var sortowEnum: sortEnum = .nazwa
	@AppStorage("sortowRosn") var sortowRosn: Bool = true

	@AppStorage("filtrAlkGlownyRum") var filtrAlkGlownyRum: Bool = true
	@AppStorage("filtrAlkGlownyWhiskey") var filtrAlkGlownyWhiskey: Bool = true
	@AppStorage("filtrAlkGlownyTequila") var filtrAlkGlownyTequila: Bool = true
	@AppStorage("filtrAlkGlownyBrandy") var filtrAlkGlownyBrandy: Bool = true
	@AppStorage("filtrAlkGlownyGin") var filtrAlkGlownyGin: Bool = true
	@AppStorage("filtrAlkGlownyVodka") var filtrAlkGlownyVodka: Bool = true
	@AppStorage("filtrAlkGlownyChampagne") var filtrAlkGlownyChampagne: Bool = true
	@AppStorage("filtrAlkGlownyInny") var filtrAlkGlownyInny: Bool = true

	@AppStorage("filtrSlodkoscNieSlodki") var filtrSlodkoscNieSlodki: Bool = true
	@AppStorage("filtrSlodkoscLekkoSlodki") var filtrSlodkoscLekkoSlodki: Bool = true
	@AppStorage("filtrSlodkoscSlodki") var filtrSlodkoscSlodki: Bool = true
	@AppStorage("filtrSlodkoscBardzoSlodki") var filtrSlodkoscBardzoSlodki: Bool = true

	@AppStorage("filtrMocBezalk") var filtrMocBezalk: Bool = true
	@AppStorage("filtrMocDelik") var filtrMocDelik: Bool = true
	@AppStorage("filtrMocSredni") var filtrMocSredni: Bool = true
	@AppStorage("filtrMocMocny") var filtrMocMocny: Bool = true

	@AppStorage("opcjonalneWymagane") var opcjonalneWymagane: Bool = false
	@AppStorage("zamiennikiDozwolone") var zamiennikiDozwolone: Bool = false
	@AppStorage("tylkoUlubione") var tylkoUlubione: Bool = false
	@AppStorage("tylkoDostepne") var tylkoDostepne: Bool = false

	@AppStorage("sklBrakiMin") var sklBrakiMin: Int = 0
	@AppStorage("sklBrakiMax") var sklBrakiMax: Int = 0
	
	init(
		zalogowany: Bool = false,
		uzytkownik: String = "",
		uzytkownikMail: String = "",

		sortowEnum: sortEnum = .nazwa,
		sortowRosn: Bool = true,
		
		filtrAlkGlownyRum: Bool = true,
		filtrAlkGlownyWhiskey: Bool = true,
		filtrAlkGlownyTequila: Bool = true,
		filtrAlkGlownyBrandy: Bool = true,
		filtrAlkGlownyGin: Bool = true,
		filtrAlkGlownyVodka: Bool = true,
		filtrAlkGlownyChampagne: Bool = true,
		filtrAlkGlownyInny: Bool = true,

		filtrSlodkoscNieSlodki: Bool = true,
		filtrSlodkoscLekkoSlodki: Bool = true,
		filtrSlodkoscSlodki: Bool = true,
		filtrSlodkoscBardzoSlodki: Bool = true,

		filtrMocBezalk: Bool = true,
		filtrMocDelik: Bool = true,
		filtrMocSredni: Bool = true,
		filtrMocMocny: Bool = true,

		opcjonalneWymagane: Bool = false,
		zamiennikiDozwolone: Bool = true,
		tylkoUlubione: Bool = false,
		tylkoDostepne: Bool = true )
	{
		self.zalogowany = zalogowany
		self.uzytkownik = uzytkownik
		self.uzytkownikMail = uzytkownikMail

		self.sortowEnum = sortowEnum
		self.sortowRosn = sortowRosn
		
		self.filtrAlkGlownyRum = filtrAlkGlownyRum
		self.filtrAlkGlownyWhiskey = filtrAlkGlownyWhiskey
		self.filtrAlkGlownyTequila = filtrAlkGlownyTequila
		self.filtrAlkGlownyBrandy = filtrAlkGlownyBrandy
		self.filtrAlkGlownyGin = filtrAlkGlownyGin
		self.filtrAlkGlownyVodka = filtrAlkGlownyVodka
		self.filtrAlkGlownyChampagne = filtrAlkGlownyChampagne
		self.filtrAlkGlownyInny = filtrAlkGlownyInny

		self.filtrSlodkoscNieSlodki = filtrSlodkoscNieSlodki
		self.filtrSlodkoscLekkoSlodki = filtrSlodkoscLekkoSlodki
		self.filtrSlodkoscSlodki = filtrSlodkoscSlodki
		self.filtrSlodkoscBardzoSlodki = filtrSlodkoscBardzoSlodki

		self.filtrMocBezalk = filtrMocBezalk
		self.filtrMocDelik = filtrMocDelik
		self.filtrMocSredni = filtrMocSredni
		self.filtrMocMocny = filtrMocMocny

		self.opcjonalneWymagane = opcjonalneWymagane
		self.zamiennikiDozwolone = zamiennikiDozwolone
		self.tylkoUlubione = tylkoUlubione
		self.tylkoDostepne = tylkoDostepne
	}

	func loadDefault() {
		zalogowany = false
		uzytkownik = ""
		uzytkownikMail = ""

		sortowEnum = .nazwa
		sortowRosn = true

		filtrAlkGlownyRum = true
		filtrAlkGlownyWhiskey = true
		filtrAlkGlownyTequila = true
		filtrAlkGlownyBrandy = true
		filtrAlkGlownyGin = true
		filtrAlkGlownyVodka = true
		filtrAlkGlownyChampagne = true
		filtrAlkGlownyInny = true

		filtrSlodkoscNieSlodki = true
		filtrSlodkoscLekkoSlodki = true
		filtrSlodkoscSlodki = true
		filtrSlodkoscBardzoSlodki = true

		filtrMocBezalk = true
		filtrMocDelik = true
		filtrMocSredni = true
		filtrMocMocny = true

		opcjonalneWymagane = false
		zamiennikiDozwolone = true
		tylkoUlubione = false
		tylkoDostepne = true
	}
}
