import SwiftData
import Foundation

func loadSklZamiennikiCSV_V(modelContext: ModelContext) {
	print("Start loadSklZamiennikiCSV_V")
	let nazwaPliku = "DTeka - SkladnikiZamienniki"
	let iloscKolumn = 2
	
	guard let filePath = Bundle.main.path(forResource: nazwaPliku, ofType: "tsv") else {
		print("Plik \(nazwaPliku) nie znaleziony")
		return
	}
	
	do {
		let zawartoscPliku = try String(contentsOfFile: filePath, encoding: .utf8)
		let rows = zawartoscPliku.components(separatedBy: "\n").dropFirst()
		
			// 1. Pobierz wszystkie skladniki z modelContext
		let fetchDescriptor = FetchDescriptor<Skl_M>()
		let skladniki = try modelContext.fetch(fetchDescriptor)
		print(skladniki.count)
		
			// 2. Utwórz słownik dla szybkiego dostępu po skladnikID
		let skladnikMap = Dictionary(uniqueKeysWithValues: skladniki.map { ($0.sklID, $0) })
		
		for row in rows {
			let kolumny = row.components(separatedBy: "\t") // Kolumny odseparowane tabulatorem
			if kolumny.count >= iloscKolumn { // Sprawdzenie czy ilość kolumn się zgadza
				let skladnikID = kolumny[0]
				let zamiennikID = kolumny[1]
				
					// 3. Znajdź skladnik po skladnikID
				if let powiazanySkladnik = skladnikMap[skladnikID] {
					
						// 4. Znajdź zamiennik po zamiennikID
					if let powiazanyZamiennik = skladnikMap[zamiennikID] {
						print("Skladnik: \(powiazanySkladnik.sklNazwa), zamiennik \(powiazanyZamiennik.sklNazwa)")
						
							// 5. Dodaj przepis do relacji
						powiazanySkladnik.sklZamArray.append(powiazanyZamiennik)
						
							// 6. Zapisz do modelContext
						modelContext.insert(powiazanyZamiennik)
					}
				} else {
					print("Nie znaleziono skladnika o ID: \(skladnikID)")
				}
			}
		}
	} catch {
		print("Błąd wczytywania pliku \(nazwaPliku): \(error)")
	}
}
