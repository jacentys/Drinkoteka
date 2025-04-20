import SwiftData
import Foundation

func loadDrinkiPrzepisyCSV_V(modelContext: ModelContext) {
	print("Start loadDrinkiPrzepisyCSV_V")
	let nazwaPliku = "DTeka - DrinkiPrzepisy"
	let iloscKolumn = 4
	
	guard let filePath = Bundle.main.path(forResource: nazwaPliku, ofType: "tsv") else {
		print("Plik \(nazwaPliku) nie znaleziony")
		return
	}
	
	do {
		let zawartoscPliku = try String(contentsOfFile: filePath, encoding: .utf8)
		let rows = zawartoscPliku.components(separatedBy: "\n").dropFirst()
		
			// 1. Pobierz wszystkie drinki z modelContext
		let fetchDescriptor = FetchDescriptor<Drink_M>()
		let drinki = try modelContext.fetch(fetchDescriptor)
		
			// 2. Utwórz słownik dla szybkiego dostępu po drinkID
		let drinkMap = Dictionary(uniqueKeysWithValues: drinki.map { ($0.drinkID, $0) })
		
		for row in rows {
			let kolumny = row.components(separatedBy: "\t")
			if kolumny.count == iloscKolumn {
				let drinkID = kolumny[0]
				let no = Int(kolumny[1]) ?? 0
				let opis = kolumny[2].trimmingCharacters(in: .whitespacesAndNewlines)
				let opcjonalne = Bool(kolumny[3]) ?? false
				
					// 3. Znajdź drink po drinkID
				if let powiazanyDrink = drinkMap[drinkID] {
						// 4. Utwórz nowy przepis z relacją do drinka
					let drinkPrzepis = DrinkPrzepis_M(
						relacjaDrink: powiazanyDrink,
						drinkID: drinkID,
						przepNo: no,
						przepOpis: opis,
						przepOpcja: opcjonalne
					)
					
						// 5. Dodaj przepis do relacji
					powiazanyDrink.drPrzepis.append(drinkPrzepis)
					
						// 6. Zapisz do modelContext
					modelContext.insert(drinkPrzepis)
				} else {
					print("Nie znaleziono drinka o drinkID: \(drinkID)")
				}
			}
		}
	} catch {
		print("Błąd wczytywania pliku \(nazwaPliku): \(error)")
	}
}
