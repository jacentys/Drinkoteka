import SwiftUI

class PrefClass_VM: ObservableObject {
	@AppStorage("zalogowany") var zalogowany: Bool?
	@AppStorage("uzytkownik") var uzytkownik: String?
	@AppStorage("uzytkownikMail") var uzytkownikMail: String?

	@AppStorage("sortowEnum") var sortowEnum: sortEnum?
	@AppStorage("sortowRosn") var sortowRosn: Bool?

	@AppStorage("filtrAlkGlownyRum") var filtrAlkGlownyRum: Bool?
	@AppStorage("filtrAlkGlownyWhiskey") var filtrAlkGlownyWhiskey: Bool?
	@AppStorage("filtrAlkGlownyTequila") var filtrAlkGlownyTequila: Bool?
	@AppStorage("filtrAlkGlownyBrandy") var filtrAlkGlownyBrandy: Bool?
	@AppStorage("filtrAlkGlownyGin") var filtrAlkGlownyGin: Bool?
	@AppStorage("filtrAlkGlownyVodka") var filtrAlkGlownyVodka: Bool?
	@AppStorage("filtrAlkGlownyChampagne") var filtrAlkGlownyChampagne: Bool?
	@AppStorage("filtrAlkGlownyInny") var filtrAlkGlownyInny: Bool?

	@AppStorage("filtrSlodkoscNieSlodki") var filtrSlodkoscNieSlodki: Bool?
	@AppStorage("filtrSlodkoscLekkoSlodki") var filtrSlodkoscLekkoSlodki: Bool?
	@AppStorage("filtrSlodkoscSlodki") var filtrSlodkoscSlodki: Bool?
	@AppStorage("filtrSlodkoscBardzoSlodki") var filtrSlodkoscBardzoSlodki: Bool?

	@AppStorage("filtrMocBezalk") var filtrMocBezalk: Bool?
	@AppStorage("filtrMocDelik") var filtrMocDelik: Bool?
	@AppStorage("filtrMocSredni") var filtrMocSredni: Bool?
	@AppStorage("filtrMocMocny") var filtrMocMocny: Bool?

	@AppStorage("opcjonalneWymagane") var opcjonalneWymagane: Bool?
	@AppStorage("zamiennikiDozwolone") var zamiennikiDozwolone: Bool?
	@AppStorage("tylkoUlubione") var tylkoUlubione: Bool?
	@AppStorage("tylkoDostepne") var tylkoDostepne: Bool?

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
