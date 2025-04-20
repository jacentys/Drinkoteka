import SwiftData
import Foundation


func loadZamCSV(modelContext: ModelContext) {
		let nazwaPliku = "zamienniki"
		let iloscKolumn = 2
		
		guard let filePath = Bundle.main.path(forResource: nazwaPliku, ofType: "tsv") else {
			print("Plik \(nazwaPliku) nie znaleziony")
			return
		}
		do {
			let zawartoscPliku = try String(contentsOfFile: filePath, encoding: .utf8)
			let rows = zawartoscPliku.components(separatedBy: "\n").dropFirst()
			
			for row in rows {
				let kolumny = row.components(separatedBy: "\t") // Kolumny odseparowane tabulatorem
				if kolumny.count >= iloscKolumn { // Sprawdzenie czy ilość kolumn się zgadza
					let skladnikID = kolumny[0]
					let zamiennikID = kolumny[1]
					
					let zamiennik = SklZamiennik(
						skladnikID: skladnikID,
						zamiennikID: zamiennikID
					)
					
					modelContext.insert(zamiennik)
				}
			}
		} catch {
			print("Błąd wczytywania pliku \(nazwaPliku): \(error)")
		}
	}
