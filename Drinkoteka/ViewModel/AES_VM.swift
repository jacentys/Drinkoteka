import Foundation
import CryptoKit

let key = SymmetricKey(size: .bits256)


// MARK: ENCRYPT AES DATA
func encryptData(data: Data, key: SymmetricKey) -> Data? {
	do {
			// AES-GCM zapewnia zarówno szyfrowanie, jak i uwierzytelnianie danych
		let sealedBox = try AES.GCM.seal(data, using: key)

			// Zwracamy zaszyfrowane dane (w tym IV i tag autentykacji)
		return sealedBox.combined
	} catch {
		print("Błąd szyfrowania: \(error)")
		return nil
	}
}

// MARK: DECRYPT AES DATA
func decryptData(encryptedData: Data, key: SymmetricKey) -> Data? {
	do {
			// Zdeszyfrowanie danych przy użyciu AES-GCM
		let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
		let decryptedData = try AES.GCM.open(sealedBox, using: key)

		return decryptedData
	} catch {
		print("Błąd deszyfrowania: \(error)")
		return nil
	}
}
