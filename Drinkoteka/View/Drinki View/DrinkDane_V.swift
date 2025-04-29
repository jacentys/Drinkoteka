import SwiftUI

struct DrinkDane_V: View {
	@Bindable var drink: Dr_M
	
	let szerokosc: CGFloat = 90
	let wysokoscSkali: CGFloat = 15
	
	var body: some View {
		HStack(spacing: 0) { // MARK: DELIK-SŁODK
								
					Spacer()

					// MARK: - Słodycz
				if drink.drSlodycz != drSlodyczEnum.brakDanych {
					VStack{
						Spacer()
						DrinkSkala_V(drink: drink, wielkosc: 25, etykieta: false)
						Spacer()
						Text("Słodycz".uppercased())
							.font(.caption2)
					}
					.frame(maxWidth: .infinity)

					Spacer()
					
					Divider()
						.frame(minWidth: 2)
						.frame(height: 50)
						.overlay(Color.accent)
				}

					Spacer()

					// MARK: - Kalorie
					VStack{
						Spacer()
						Text("\(drink.drKal)")
							.font(.largeTitle)
							.fontWeight(.thin)
						Spacer()
						Text("Kalorie".uppercased())
							.font(.caption2)
					}
					.frame(maxWidth: .infinity)

					Spacer()
					Divider()
					.frame(minWidth: 2)
					.frame(height: 50)
					.overlay(Color.accent)
					Spacer()

					// MARK: - Ulubiony
					VStack {
						Spacer()
						Image(systemName: drink.drUlubiony ? "star.fill" : "star")
							.font(.system(size: 25))
							.foregroundStyle(drink.drUlubiony ? Color.accent : Color.gray)
							.onTapGesture {
								drink.ulubionyToggle()
							}
						Spacer()
						Text("Ulubiony".uppercased())
							.font(.caption2)
					}
					.frame(maxWidth: .infinity)

					Spacer()
			}

			.padding(.vertical, 16)
			.background(RoundedRectangle(cornerRadius: 12)
				.foregroundStyle(.regularMaterial))

	}
}

#Preview {
	NavigationStack {
		DrinkDane_V(drink: drMock())
	}
}
