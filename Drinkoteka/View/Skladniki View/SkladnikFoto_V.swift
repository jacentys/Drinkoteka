import SwiftUI

struct SkladnikFoto_V: View {
	@Bindable var skladnik: Skl_M

	let wysokosc: CGFloat = 300
	
	var body: some View {
			ZStack {
				RoundedRectangle(cornerRadius: 12)
					.frame(height: wysokosc - 20)
					.foregroundStyle(skladnik.getColor())
					.opacity(0.3)
				Circle()
					.stroke(skladnik.getColor(), lineWidth: 5)
					.fill(.regularMaterial)
					.frame(width: wysokosc, height: wysokosc)
				
					// MARK: FOTO
				Image(!skladnik.sklFoto.isEmpty ? skladnik.sklFoto : "butelka-plyn")
					.resizable()
					.scaledToFit()
					.frame(width: wysokosc, height: wysokosc)
					.mask(Circle())
					.foregroundColor(skladnik.getColor().opacity(0.3))
				Image(!skladnik.sklFoto.isEmpty ? skladnik.sklFoto : "butelka")
					.resizable()
					.scaledToFit()
					.frame(width: wysokosc, height: wysokosc)
					.mask(Circle())
					.foregroundColor(Color.primary)
				Text(skladnik.sklNazwa)
					.foregroundStyle(Color.gray)
					.fontWidth(.compressed)
					.fontWeight(.black)
					.offset(y: 28)
				
				HStack {
					Spacer()
					VStack(spacing: 0) {
						Spacer()
						IkonaJestBrak_V(
							skladnik: skladnik,
							txtShow: true,
							wielkosc: 40)
							.frame(width: 100, height: 100)
					}
				}
				.frame(height: wysokosc)
			}
	}
}

#Preview {
	Text("Test")
	NavigationStack {
//		SkladnikFotoView(sklSelID: "smietana")
	}
}
