import SwiftUI

struct Background_V: View {
	@State var foto: String
	@State var kolor: Color = Color.accent
	
	var body: some View {
		ZStack {
			Back_V(kolor: kolor)
			Text("\(kolor), \(foto)")
				.font(.largeTitle)
			Image(foto) // MARK: FOTA Z MASKĄ NA TŁO
				.resizable()
				.scaledToFit()
				.clipped()
			
			Rectangle() // MARK: NA WIERZCHU EFEKT SZKLA
				.foregroundStyle(.ultraThinMaterial)
				.ignoresSafeArea()
		}
	}
}

#Preview {
	Background_V(foto: "whiskey", kolor: .red)
}
