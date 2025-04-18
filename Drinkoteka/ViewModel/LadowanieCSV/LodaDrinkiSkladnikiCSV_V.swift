import SwiftData
import Foundation

func loadDrinkiSkladnikiCSV_V(modelContext: ModelContext) {
	let nazwaPliku = "Barman - DrinkiSkladniki"
	let iloscKolumn = 6
	
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
			let kolumny = row.components(separatedBy: "\t") // Kolumny odseparowane tabulatorem
			if kolumny.count == iloscKolumn { // Sprawdzenie czy ilość kolumn się zgadza
				let drinkID = kolumny[0]
				let skladnikID = kolumny[1]
				let ilosc = Double(kolumny[2].replacingOccurrences(of: ",", with: ".")) ?? 0
				let miara = strtoMiaraEnum(string: kolumny[3])
				let info = kolumny[4]
				let opcja = Bool(kolumny[5]) ?? false

					// 3. Znajdź drink po drinkID
				if let powiazanyDrink = drinkMap[drinkID] {
					let numer = powiazanyDrink.drSklad.count + 1
						// 4. Utwórz nowy przepis z relacją do drinka
					let drinkSklad = DrinkSkladnik_M(
						relacjaDrink: powiazanyDrink,
						drinkID: drinkID,
						skladnikID: skladnikID,
						sklNo: numer,
						sklIlosc: ilosc,
						sklMiara: miara,
						sklInfo: info,
						sklOpcja: opcja
					)

						// 5. Dodaj przepis do relacji
					powiazanyDrink.drSklad.append(drinkSklad)
					
						// 6. Zapisz do modelContext
					modelContext.insert(drinkSklad)
				} else {
					print("Nie znaleziono drinka o drinkID: \(drinkID)")
				}
			}
		}
	} catch {
		print("Błąd wczytywania pliku \(nazwaPliku): \(error)")
	}
}
