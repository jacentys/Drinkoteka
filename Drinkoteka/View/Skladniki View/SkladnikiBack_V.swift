import SwiftUI

struct SkladnikiBack_V: View {
	@Bindable var skladnik: Skl_M
	
	var body: some View {
		ZStack {
			Back_V(kolor: skladnik.getKolor())
				.font(.largeTitle)
			DrinkotekaImage_V(nazwa: skladnik.sklFoto) // MARK: FOTA Z MASKĄ NA TŁO
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
