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
			Image(!drink.drFoto.isEmpty ? drink.drFoto :  drink.drSzklo.foto)
				.resizable()
				.scaledToFit()
				.frame(maxHeight: .infinity)
//				.mask(Circle().frame(width: ekranSzer, height: wysokosc))
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
