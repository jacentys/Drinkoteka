import SwiftData
import Foundation

func loadSklZamiennikiCSV_VM(modelContext: ModelContext) {
		//	print("Start loadSklZamiennikiCSV_VM")
	guard let filePath = Bundle.main.path(forResource: "DTeka - SkladnikiZamienniki", ofType: "tsv") else { return }

	do {
			// Clear existing relations
		try modelContext.fetch(FetchDescriptor<SklZamiennik_M>())
			.forEach { modelContext.delete($0) }

			// Ładuj map składników
		let skladniki = try modelContext.fetch(FetchDescriptor<Skl_M>())
		let skladnikiMap = Dictionary(uniqueKeysWithValues: skladniki.map { ($0.sklID, $0) })

			// Process relations
		var dodaneRelacje = Set<String>()

		try String(contentsOfFile: filePath, encoding: .utf8)
			.components(separatedBy: .newlines)
			.filter { !$0.isEmpty }
			.dropFirst()
			.forEach { row in
				let kolumny = row.components(separatedBy: "\t")
				guard kolumny.count >= 2 else { return }

				let skladnikID = clearStr(kolumny[0])
				let zamiennikID = clearStr(kolumny[1])
				let relacjaID = "\(skladnikID)->\(zamiennikID)"

				if !dodaneRelacje.contains(relacjaID),
					let skladnik = skladnikiMap[skladnikID],
					let zamiennik = skladnikiMap[zamiennikID] {

						print("Przed: Skladnik: \(skladnik.sklNazwa), \(skladnik.sklStan)")
						print("Przed: Zamiennik: \(zamiennik.sklNazwa), \(zamiennik.sklStan)")

					modelContext.insert(SklZamiennik_M(skladnik: skladnik, zamiennik: zamiennik))
					dodaneRelacje.insert(relacjaID)

					
					/// Ustawianie skladnik.sklStan w zależności od zamiennika.
					if skladnik.sklStan == .brak {
						if zamiennik.sklStan == .jest {
							skladnik.sklStan = .zmJest
						}
						if zamiennik.sklStan == .brak {
							skladnik.sklStan = .zmBrak
						}
					}
					if skladnik.sklStan == .zmBrak && zamiennik.sklStan == .jest {
						skladnik.sklStan = .zmJest
					}

					
					print("Po: Skladnik: \(skladnik.sklNazwa), \(skladnik.sklStan)")
					print("Po: Zamiennik: \(zamiennik.sklNazwa), \(zamiennik.sklStan)")

				}
			}

		try modelContext.save()
	} catch {
		print("Błąd wczytywania zamienników: \(error)")
	}
		//	print("Koniec loadSklZamiennikiCSV_VM")
}
