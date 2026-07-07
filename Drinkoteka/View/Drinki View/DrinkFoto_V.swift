import SwiftUI

struct DrinkFoto_V: View {
	
	@Bindable var drink: Dr_M
	let wysokosc: CGFloat = 200
	
	var body: some View {

		ZStack {
			RoundedRectangle(cornerRadius: 12)
				.frame(height: wysokosc - 20)
				.opacity(0.3)
			Circle()
				.fill(.regularMaterial)
				.frame(width: wysokosc, height: wysokosc)
			
				// MARK: FOTO
			DrinkotekaImage_V(nazwa: drink.drFoto, fallback: drink.drSzklo.foto)
				.scaledToFit()
				.frame(maxHeight: .infinity)
				.frame(height: wysokosc-50)
				.foregroundColor(Color.primary)
			
		}
	}
}

#Preview {
	NavigationStack {
		DrinkFoto_V(drink: drMock())
	}
}
