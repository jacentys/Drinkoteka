import SwiftUI

struct DrinkBack_V: View {
	@Bindable var drink: Dr_M
	
	var body: some View {
		ZStack {
			Back_V(kolor: drink.getKolor())
				.font(.largeTitle)
			Image(drink.drFoto) // MARK: FOTA Z MASKĄ NA TŁO
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
	DrinkBack_V(drink: drMock())
}
