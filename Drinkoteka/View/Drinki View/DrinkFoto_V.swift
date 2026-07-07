import SwiftUI

struct DrinkFoto_V: View {
	
	@Bindable var drink: Dr_M
	let wysokosc: CGFloat = 200
//	let ekranSzer: CGFloat = UIScreen.main.bounds.size.width
	
	var body: some View {

		ZStack {
			RoundedRectangle(cornerRadius: 12)
				.frame(height: wysokosc - 20)
//				.foregroundStyle(drink.getKolor())
				.opacity(0.3)
			Circle()
//				.stroke(drink.getKolor(), lineWidth: 5)
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
