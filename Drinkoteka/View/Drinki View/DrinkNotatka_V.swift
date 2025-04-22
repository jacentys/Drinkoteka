import SwiftUI

struct DrinkNotatka_V: View {
	@Bindable var drink: Dr_M

	var body: some View {
			if drink.drNotatka == "" {
				Button {
//					drinkiClass.updateDrinkUlubiony(drink: drink)
				} label: {
					Text("Dodaj Notatkę")
						.font(.headline)
						.frame(maxWidth: .infinity)
						.frame(height: 54)
						.foregroundColor(Color.white)
						.background(Color.accent)
						.cornerRadius(8)
				}
			} else {
				
				ZStack {
					VStack(alignment: .leading) {
						
							// MARK: Nagłówek
						HStack(alignment: .firstTextBaseline) {
							Text("Notatka:".uppercased())
								.TitleStyle()
							
							Spacer()
							
							Button {
								
							} label: {
								Text("Edytuj".uppercased())
									.background(.accent)
									.frame(height: 54)
									.frame(maxWidth: .infinity)
							}
						}
						
							// MARK: TEKST NOTATKI
						Text("\(drink.drNotatka)")
							.fontWeight(.light)
							.multilineTextAlignment(.leading)
					}
					.padding(20)
					.background(
						RoundedRectangle(cornerRadius: 12)
							.foregroundStyle(.regularMaterial))
				}

			}
	}
}

#Preview {
	NavigationStack {
		Text("Notatka V")
//		DrinkNotatka(drSelID: drink.id)
	}
}
