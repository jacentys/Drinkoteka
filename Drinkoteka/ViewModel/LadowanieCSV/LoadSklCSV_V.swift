import SwiftData
import Foundation

func loadSklaCSV_V(modelContext: ModelContext) {
	print("Start loadSklaCSV_V")
	let nazwaPliku = "DTeka - Skladniki"
	let iloscKolumn = 11
	
	guard let filePath = Bundle.main.path(forResource: nazwaPliku, ofType: "tsv") else {
		print("Plik \(nazwaPliku) nie znaleziony")
		return
	}
	do {
		let zawartoscPliku = try String(contentsOfFile: filePath, encoding: .utf8)
		let rows = zawartoscPliku.components(separatedBy: "\n").dropFirst()
		
		for row in rows {
			let kolumny = row.components(separatedBy: "\t") // Kolumny odseparowane tabulatorem
			if kolumny.count == iloscKolumn { // Sprawdzenie czy ilość kolumn się zgadza
				
				let sklID = kolumny[0]
				let nazwa = kolumny[1]
				let kategoria = kolumny[2]
				let procenty = Int(kolumny[3])
				let kolor = kolumny[4]
				let foto = kolumny[5] == "" ? "butelka" : kolumny[5]
				let stan = kolumny[6]
				let opis = kolumny[7]
				let kalorie = Int(kolumny[8])
				let miara = kolumny[9]
				let sklWWW = kolumny[10]
				
				let skladniczek = Skladnik(
					sklID: sklID,
					sklNazwa: nazwa,
					sklKat: kategoria,
					sklProc: procenty,
					sklKolor: kolor,
					sklFoto: foto,
					sklStan: stan,
					sklOpis: opis,
					sklKal: kalorie,
					sklMiara: miara,
					sklWWW: sklWWW,
					sklZamArray: []
				)
				sklArray.append(skladniczek)
			}
		}
	} catch {
		print("Błąd wczytywania pliku \(nazwaPliku): \(error)")
	}
} // LOAD SKLADNIKI FROM CSV
