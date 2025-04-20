import SwiftData
import Foundation

func DeleteSkl_V(modelContext: ModelContext) {
	print("Start DeleteSkl_V")


			// 1. Utwórz słownik dla szybkiego dostępu po skladnikID
		let skladnikMap = Dictionary(uniqueKeysWithValues: skladniki.map { ($0.sklID, $0) })
		
		for skladnikMap in rows {
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
}
