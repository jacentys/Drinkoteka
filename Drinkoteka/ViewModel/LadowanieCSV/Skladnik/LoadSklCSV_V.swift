import SwiftData
import Foundation

func loadSklCSV_V(modelContext: ModelContext) {
	print("Start loadSklCSV_V")
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
				let sklNazwa = kolumny[1]
				let sklKat = strToSklKatEnum(kolumny[2])
				let sklProc = Int(kolumny[3]) ?? 0
				let sklKolor = kolumny[4]
				let sklFoto = kolumny[5] == "" ? "butelka" : kolumny[5]
				let sklStan = strToSklStanEnum(kolumny[6])
				let sklOpis = kolumny[7]
				let sklKal = Int(kolumny[8]) ?? 0
				let sklMiara = strToSklMiaraEnum(kolumny[9])
				let sklWWW = kolumny[10]
				
				let skladnik = Skl_M(
					sklID: sklID,
					sklNazwa: sklNazwa,
					sklKat: sklKat,
					sklProc: sklProc,
					sklKolor: sklKolor,
					sklFoto: sklFoto,
					sklStan: sklStan,
					sklOpis: sklOpis,
					sklKal: sklKal,
					sklMiara: sklMiara,
					sklWWW: sklWWW,
					sklZamArray: []
				)
				modelContext.insert(skladnik)
			}
		}
	} catch {
		print("Błąd wczytywania pliku \(nazwaPliku): \(error)")
	}
}
