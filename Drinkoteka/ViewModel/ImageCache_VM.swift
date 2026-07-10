// Prosty cache obrazów (pamięć + dysk) dla grafik pobieranych zdalnie.
import UIKit

// Trwały magazyn zdjęć własnych drinków (katalog Documents — nie kasowany jak cache).
// Referencja zapisywana w Dr_M.drFoto ma postać "file:<uuid>.jpg".
enum DrinkPhotoStore {
    static let prefix = "file:"

    private static var folder: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("DrinkPhotos", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    // Zapisuje obraz jako JPEG i zwraca referencję do wpisania w drFoto (lub nil).
    static func save(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return nil }
        let name = UUID().uuidString + ".jpg"
        do {
            try data.write(to: folder.appendingPathComponent(name), options: .atomic)
            return prefix + name
        } catch {
            return nil
        }
    }

    // Wczytuje obraz dla referencji "file:...". Zwraca nil dla assetów/URL.
    static func load(_ ref: String) -> UIImage? {
        guard ref.hasPrefix(prefix) else { return nil }
        let name = String(ref.dropFirst(prefix.count))
        guard let data = try? Data(contentsOf: folder.appendingPathComponent(name)) else { return nil }
        return UIImage(data: data)
    }

    static func isLocalPhoto(_ ref: String) -> Bool { ref.hasPrefix(prefix) }
}

actor ImageCache {
    static let shared = ImageCache()

    private let folder: URL = {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let dir = caches.appendingPathComponent("DrinkotekaImages", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    // MARK: - Pobierz (cache dysk → sieć)

    func image(for urlString: String) async -> UIImage? {
        // 1. Sprawdź dysk
        if let cached = loadFromDisk(key: urlString) { return cached }

        // 2. Pobierz z sieci
        guard let url = URL(string: urlString) else { return nil }
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let image = UIImage(data: data) else { return nil }

        // 3. Zapisz na dysk
        saveToDisk(key: urlString, data: data)
        return image
    }

    // MARK: - Usuń cały cache (wywołaj przy resetAll)

    func clearAll() {
        try? FileManager.default.removeItem(at: folder)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    }

    // MARK: - Prywatne

    private func filePath(for key: String) -> URL {
        // Klucz → bezpieczna nazwa pliku
        let safe = key
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .replacingOccurrences(of: ".", with: "_")
        return folder.appendingPathComponent(safe + ".jpg")
    }

    private func loadFromDisk(key: String) -> UIImage? {
        let path = filePath(for: key)
        guard let data = try? Data(contentsOf: path) else { return nil }
        return UIImage(data: data)
    }

    private func saveToDisk(key: String, data: Data) {
        let path = filePath(for: key)
        try? data.write(to: path, options: .atomic)
    }
}
