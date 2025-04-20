import SwiftData
import Foundation

func loadDrCSV_V(modelContext: ModelContext){
	print("Start loadDrinkiCSV_V")
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
				
				let drinkID = kolumny[0]
				let nazwa = kolumny[1]
				let kategoria = stringToDrKat(kolumny[2])
				let zrodlo = kolumny[3]
				let kolor = kolumny[4]
				let foto = kolumny[5] != "" ? kolumny[5] : stringToSzklo(string: kolumny[7]).foto
				let procenty = Int(kolumny[6]) ?? 0
				let slodycz = stringToDrinkSlodycz(kolumny[7])
				let szklo = stringToSzklo(string: kolumny[8])
				let ulubiony = Bool(kolumny[9]) ?? false
				let notatka = kolumny[10]
				let uwagi = kolumny[11]
				let drWWW = kolumny[12]
				let mocDrinka = setMocDrinka(procenty: Int(kolumny[5]) ?? 0)
				let brakuje = 0
				let alkGlowny: [alkGlownyEnum] = []
				let skladniki: [DrinkSkladnik_M] = []
				let przepisy: [DrinkPrzepis_M] = []

				let drineczek = Drink_M(
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
					drKalorie: 0,
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
