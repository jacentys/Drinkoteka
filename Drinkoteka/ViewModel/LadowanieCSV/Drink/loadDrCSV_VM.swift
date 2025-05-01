import SwiftData
import Foundation

func loadDrCSV_VM(modelContext: ModelContext) {
	print("Start loadDrCSV_V")
	let nazwaPliku = "DTeka - Drinki"
	let iloscKolumn = 13
	
	guard let filePath = Bundle.main.path(forResource: nazwaPliku, ofType: "tsv") else {
		print("Plik \(nazwaPliku) nie znaleziony")
		return
	}
	do {
		let zawartoscPliku = try String(contentsOfFile: filePath, encoding: .utf8)
		let rows = zawartoscPliku.components(separatedBy: "\n").dropFirst()
		
		for row in rows {
			let kolumny = row.components(separatedBy: "\t") // Tab separat.
			if kolumny.count == iloscKolumn { // Ilość kolumn się zgadza?
				
				let drinkID = clearStr(kolumny[0])
				let nazwa = kolumny[1]
				let kategoria = strToDrKatEnum(kolumny[2])
				let zrodlo = kolumny[3]
				let kolor = kolumny[4]
				let foto = kolumny[5] != "" ? kolumny[5] : strToDrSzklo(kolumny[8]).foto
				let procenty = Int(kolumny[6]) ?? 0
				let slodycz = strToDrSlodycz(kolumny[7])
				let szklo = strToDrSzklo(kolumny[8])
				let ulubiony = strToBool(kolumny[9])
				let notatka = kolumny[10]
				let uwagi = kolumny[11]
				let drWWW = kolumny[12]
				let mocDrinka = strToDrMoc(kolumny[6])
				let brakuje = 0
				let alkGlowny: [alkGlownyEnum] = []
				let skladniki: [DrSkladnik_M] = []
				let przepisy: [DrPrzepis_M] = []

				let drineczek = Dr_M(
					drinkID: drinkID,
					drNazwa: nazwa,
					drKat: kategoria,
					drZrodlo: zrodlo,
					drKolor: kolor,
					drFoto: foto,
					drProc: procenty,
					drSlodycz: slodycz,
					drSzklo: szklo,
					drUlubiony: ulubiony,
					drNotatka: notatka,
					drUwagi: uwagi,
					drWWW: drWWW,
					drKal: 0,
					drMoc: mocDrinka,
					drBrakuje: brakuje,
					drAlkGlowny: alkGlowny,
					drSklad: skladniki,
					drPrzepis: przepisy
				)
				modelContext.insert(drineczek)
			}
		}
	} catch {
		print("Błąd wczytywania pliku \(nazwaPliku): \(error)")
	}
	print("Koniec loadDrCSV_V")

}

//func getSkladnikiDrinkaFromID(drinkID: String) -> [DrinkSkladnik_M] {
//	let skladnikiFiltrowane = self.drSklArray.filter {
//		$0.drinkID == drinkID
//	}
//	return skladnikiFiltrowane
//}

//func getSkladnikiDrinkaFromID(drinkID: String) -> [DrinkSkladnik_M] {
//	let skladnikiFiltrowane = self.drSklArray.filter {
//		$0.drinkID == drinkID
//	}
//	return skladnikiFiltrowane
//}
