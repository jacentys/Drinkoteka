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
				ForEach (drink.drSklad.sorted(by: { $0.sklNo < $1.sklNo })) { skladnikDrinka in
					NavigationLink(
						destination: Skladnik_V(skladnik: skladnikDrinka.skladnik)) {
							DrinkSkladnikLinijka_V(drSkladnik: skladnikDrinka)
						}
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
		DrinkSkladniki_V(drink: drMock())
	}
}

