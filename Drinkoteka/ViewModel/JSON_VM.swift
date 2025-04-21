import Foundation

// MARK: ENCODE JSON
func encodeJSON<T: Codable>(object: T) -> String? {
	let encoder = JSONEncoder()
	encoder.outputFormatting = .prettyPrinted // Dodanie formatowania z wcięciami

	do {
		let jsonData = try encoder.encode(object)

			// Zamiana danych na czytelny String
		if let jsonString = String(data: jsonData, encoding: .utf8) {
			return jsonString
		} else {
			print("Błąd konwersji danych na tekst")
			return nil
		}
	} catch {
		print("Błąd kodowania: \(error)")
		return nil
	}
}

// MARK: DECODE JSON
func decodeJSON<T: Codable>(jsonData: Data, type: T.Type) -> T? {
	let decoder = JSONDecoder()

	do {
		let object = try decoder.decode(T.self, from: jsonData)
		return object
	} catch {
		print("Błąd dekodowania: \(error)")
		return nil
	}
}
