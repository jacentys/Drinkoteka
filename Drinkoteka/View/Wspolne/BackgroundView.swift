import SwiftUI

struct BackgroundView: View {

	let foto: String
	var kolor: Color = Color.accent
	
	var body: some View {
	
		ZStack {

			Back(kolor: kolor)

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
	BackgroundView(foto: "whiskey", kolor: .red)
}
