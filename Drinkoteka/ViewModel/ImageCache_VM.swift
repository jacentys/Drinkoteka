// Prosty cache obrazów (pamięć + dysk) dla grafik pobieranych zdalnie.
import UIKit

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
