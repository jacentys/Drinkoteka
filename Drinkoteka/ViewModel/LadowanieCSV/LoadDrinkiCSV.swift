import SwiftData
import Foundation

	// MARK: Load Drinki
func loadDrinkiCSV(modelContext: ModelContext){
	let nazwaPliku = "Barman - Drinki"
	let iloscKolumn = 13
	
	guard let filePath = Bundle.main.path(forResource: nazwaPliku, ofType: "tsv") else {
		print("Plik \(nazwaPliku) nie znaleziony")
		exit(2) // Nie jestem pewien
	}
	do {
		let zawartoscPliku = try String(contentsOfFile: filePath, encoding: .utf8)
		let rows = zawartoscPliku.components(separatedBy: "\n").dropFirst()
		
		for row in rows {
			let kolumny = row.components(separatedBy: "\t") // Tab separat.
			if kolumny.count == iloscKolumn { // Ilość kolumn się zgadza?
				
				let id = kolumny[0]
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
				
				
//				let skladniki: [DrinkSkladnik] = []
//				let przepisy: [DrinkPrzepis] = []
					//					let skladniki = getSkladnikiDrinkaFromID(drinkID: clearStr(kolumny[0]))
					//					let przepisy = getDrinkiPrzepisyByDrinkID(drinkID: clearStr(kolumny[0]))
				let mocDrinka = setMocDrinka(procenty: Int(kolumny[5]) ?? 0)
				let brakuje = 0
				let alkGlowny: [alkGlownyEnum] = []
				
				let drineczek = Drink(
					id: id,
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
//					drSklad: skladniki,
//					drPrzepis: przepisy,
					drKalorie: 0,
					drMoc: mocDrinka,
					drBrakuje: brakuje,
					drAlkGlowny: alkGlowny
				)
				modelContext.insert(drineczek)
			}
		}
	} catch {
		print("Błąd wczytywania pliku \(nazwaPliku): \(error)")
	}
	} // Load Drinki
