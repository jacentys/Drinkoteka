import SwiftUI

struct DrinkSkladniki_V: View {
	
	@Bindable var drink: Dr_M
	
	var body: some View {
		ZStack {
			VStack(alignment: .leading, spacing: 2) {
				
					// MARK: Nagłówek
				HStack(alignment: .firstTextBaseline) {
					Text("Skład:".uppercased())
						.TitleStyle()
					Spacer()
				}
				
					// Linijki
				ForEach (drink.drSklad) { skladnikDrinka in
//					NavigationLink(destination: Skladnik_V(skladnik: skladnikDrinka.skladnik)) {
					DrinkSkladnikLinijka_V(drSkladnik: skladnikDrinka)
//					}
				}
			}
		}
		.padding(20)
		.background(RoundedRectangle(cornerRadius: 12)
			.foregroundStyle(.regularMaterial))
	}
}

#Preview {
	NavigationStack {
		Text("DrinkSkladnik_V")
//		DrinkSkladnikiView(drSelID: drink.id)
	}
}

