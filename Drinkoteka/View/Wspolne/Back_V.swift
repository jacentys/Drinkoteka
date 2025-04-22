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

struct Back_V: View {
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
	func randomizeColor(by factor: CGFloat) -> Color {
#if os(iOS) || os(tvOS) || os(watchOS)
		let baseColor = UIColor(self)
		var red: CGFloat = 0
		var green: CGFloat = 0
		var blue: CGFloat = 0
		var alpha: CGFloat = 0
		baseColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
#elseif os(macOS)
		let nsColor = NSColor(self)
		guard let baseColor = nsColor.usingColorSpace(.deviceRGB) else {
			return self // nie udało się przekonwertować do RGB
		}
		var red: CGFloat = 0
		var green: CGFloat = 0
		var blue: CGFloat = 0
		var alpha: CGFloat = 0
		baseColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

#endif
		
			// Randomizacja
		let randomR = CGFloat.random(in: (red - factor)...(red + factor))
		let randomG = CGFloat.random(in: (green - factor)...(green + factor))
		let randomB = CGFloat.random(in: (blue - factor)...(blue + factor))
		
		let newRed = min(max(randomR, 0), 1)
		let newGreen = min(max(randomG, 0), 1)
		let newBlue = min(max(randomB, 0), 1)
		
#if os(iOS) || os(tvOS) || os(watchOS)
		return Color(UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: alpha))
#elseif os(macOS)
		return Color(NSColor(red: newRed, green: newGreen, blue: newBlue, alpha: alpha))
#endif
	}
}



#Preview {
	Back_V(kolor: .pink)
}
