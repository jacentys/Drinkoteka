import SwiftData
import Foundation

func loadDrAlkGlownyCSV_VM(modelContext: ModelContext) {
		//	print("Start loadSklZamiennikiCSV_VM")
	print("Start loadDrAlkGlownyCSV_V")
	let nazwaPliku = "DTeka - DrinkiAlkGlowny"
	let iloscKolumn = 2
	
	guard let filePath = Bundle.main.path(forResource: nazwaPliku, ofType: "tsv") else {
		print("Plik \(nazwaPliku) nie znaleziony")
		return
	}
	
	do {
		let zawartoscPliku = try String(contentsOfFile: filePath, encoding: .utf8)
		let rows = zawartoscPliku.components(separatedBy: "\n").dropFirst()
		
			// 1. Pobierz wszystkie drinki z modelContext
		let fetchDescriptor = FetchDescriptor<Dr_M>()
		let drinki = try modelContext.fetch(fetchDescriptor)
		
			// 2. Utwórz słownik dla szybkiego dostępu po drinkID
		let drinkMap = Dictionary(uniqueKeysWithValues: drinki.map { ($0.drinkID, $0) })
		
		for row in rows {
			let kolumny = row.components(separatedBy: "\t")
			if kolumny.count == iloscKolumn {
				let drinkID = kolumny[0]
				let alkGlowny = kolumny[1].trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
				
					// 3. Znajdź drink po drinkID
				if let powiazanyDrink = drinkMap[drinkID] {
						
						// 4. Dodaj przepis do relacji
					powiazanyDrink.drAlkGlowny.append(alkGlownyEnum(rawValue: alkGlowny) ?? alkGlownyEnum.inny)
				} else {
					print("Nie znaleziono drinka o drinkID: \(drinkID)")
				}
			}
		}
	} catch {
		print("Błąd wczytywania pliku \(nazwaPliku): \(error)")
	}
	print("Koniec loadDrAlkGlownyCSV_V")
}
