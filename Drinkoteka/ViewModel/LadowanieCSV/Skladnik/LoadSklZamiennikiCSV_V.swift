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
			let kolumny = row.components(separatedBy: "\t")
			if kolumny.count >= iloscKolumn {
				let skladnikID = clearStr(kolumny[0])
				let zamiennikID = clearStr(kolumny[1])

				if let powiazanySkladnik = skladnikMap[skladnikID] {
					print("ID: \(skladnikID) - skladnik: \(powiazanySkladnik.sklNazwa)")

					if let powiazanyZamiennik = skladnikMap[zamiennikID] {
						print("ID: \(zamiennikID) - zamiennik: \(powiazanyZamiennik.sklNazwa)")

							// Dodaj zamiennik bez tworzenia nowej instancji
						powiazanySkladnik.sklZamArray.append(powiazanyZamiennik)

							// Zapisz zmiany w modelContext
						try? modelContext.save()
					}
				} else {
					print("Nie znaleziono składnika o ID: \(skladnikID)")
				}
			}
		}
	} catch {
		print("Błąd wczytywania pliku \(nazwaPliku): \(error)")
	}
	print("Koniec loadSklZamiennikiCSV_V")
}
