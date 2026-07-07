import SwiftUI

/// Wyświetla obrazek z dwóch źródeł:
/// - jeśli `nazwa` zaczyna się od "http" → pobiera z sieci (cache dysk + URLCache)
/// - w przeciwnym razie → ładuje lokalny asset z xcassets
struct DrinkotekaImage_V: View {
    let nazwa: String
    let fallback: String

    @State private var uiImage: UIImage? = nil
    @State private var loaded = false

    init(nazwa: String, fallback: String = "") {
        self.nazwa = nazwa.isEmpty ? fallback : nazwa
        self.fallback = fallback
    }

    var body: some View {
        Group {
            if nazwa.hasPrefix("http") {
                if let img = uiImage {
                    Image(uiImage: img)
                        .resizable()
                } else {
                    ProgressView()
                        .task(id: nazwa) {
                            uiImage = await ImageCache.shared.image(for: nazwa)
                        }
                }
            } else {
                Image(nazwa.isEmpty ? fallback : nazwa)
                    .resizable()
            }
        }
    }
}
