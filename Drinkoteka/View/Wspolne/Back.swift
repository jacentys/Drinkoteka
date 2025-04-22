import SwiftUI
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
typealias OSColor = UIColor
#elseif os(macOS)
import AppKit
typealias OSColor = NSColor
#endif

let kolor1 = Color.accent
let kolor2 = Color.gray

struct BackOld: View {
	@Environment(\.colorScheme) var colorScheme
	var body: some View {
		ZStack {
			MeshGradient(width: 3, height: 3, points: [
				.init(0, 0), .init(0.5, 0), .init(1, 0),
				.init(0, 0.5), .init(0.7, 0.2), .init(1, 0.5),
				.init(0, 1), .init(0.2, 1), .init(1, 1)],
							 colors: [
								.accent, .accent, .yellow,
								.yellow, .white, .yellow,
								.yellow, .accent, .white]
			)
			.brightness(colorScheme == .dark ? -0.8 : 0)
		}
	}
}

struct Back: View {
	@Environment(\.colorScheme) var colorScheme
	@State var kolor: Color = Color.accent
	@State var xCount: Int = 5
	@State var yCount: Int = 4

	@State var punkty: [CGPoint] = []

	var body: some View {
		MeshGradient(width: xCount, height: yCount,
						 points: dodajPunkty(xCount: xCount, yCount: yCount),
						 colors: dodajKolory(xCount: xCount, yCount: yCount, tint: kolor))
		.brightness(colorScheme == .dark ? -0.8 : 0)
		.ignoresSafeArea()
	}
}

	// MARK: Array Punktów
func dodajPunkty (xCount: Int, yCount: Int) -> [SIMD2<Float>] {

	let dzielnikX: Float = 1 / (Float(xCount) - 1)
	let dzielnikY: Float = 1 / (Float(yCount) - 1)

	var punkty: [SIMD2<Float>] = []

	for idy in 0..<yCount {
		for idx in 0..<xCount {

			var x: Float = Float(idx) * dzielnikX
			var y: Float = Float(idy) * dzielnikY
			if x != 0 && x != 1 {
				x = Float.random(in: x-(dzielnikX * 0.25)...x+(dzielnikX * 0.5))
			}
			if y != 0 && y != 1 {
				y = Float.random(in: y-(dzielnikY * 0.25)...y+(dzielnikY * 0.5))
			}
			x = min(max(x, 0), 1)
			y = min(max(y, 0), 1)

			let punkt = SIMD2<Float>(x: x, y: y)

			punkty.append(punkt)  // Dodawanie punktu do tablicy
		}
	}
	return punkty
}

	// MARK: Array Kolorów
func dodajKolory (xCount: Int, yCount: Int, tint: Color) -> [Color]{
	var kolory: [Color] = []
	for _ in 0..<yCount {
		for _ in 0..<xCount {

			// Wywołuję funkcję randomizacji.
			let kolor = tint.randomizeColor(by: 0.3)
			kolory.append(kolor)
		}
	}
	return kolory
}

	// MARK: Extension Koloru
extension Color {
		// Funkcja RANDOMIZACJI
	func randomizeColor(by factor: CGFloat) -> Color {
		
		let uiColor = OSColor(self)

		var red: CGFloat = 0
		var green: CGFloat = 0
		var blue: CGFloat = 0
		var alpha: CGFloat = 0

			// Pobieramy komponenty koloru
		uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

			// Randomizujemy kolory
		let randomR = CGFloat.random(in: red-factor...red+factor)
		let randomG = CGFloat.random(in: green-factor...green+factor)
		let randomB = CGFloat.random(in: blue-factor...blue+factor)

			// Zmieniamy wartości
		red = min(max(randomR, 0), 1)
		green = min(max(randomG, 0), 1)
		blue = min(max(randomB, 0), 1)

		return Color(OSColor(red: red, green: green, blue: blue, alpha: alpha))
	}
}

#Preview {
	Back(kolor: .pink)
}
