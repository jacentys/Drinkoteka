import SwiftUI

struct DrinkSkala_V: View {
	@Bindable var drink: Dr_M
	let kolor: Color = Color.accent
	var wielkosc: CGFloat = 35
	var etykieta: Bool = true
	
	var body: some View {
		if drink.drSlodycz != drSlodyczEnum.brakDanych {

			VStack(spacing: 3) {
				Spacer()
				RoundedRectangle(cornerRadius: 2)
					.fill(
						drink.drSlodycz == drSlodyczEnum.bardzoSlodki ? kolor : Color.primary
					)
					.frame(width: wielkosc, height: wielkosc * 0.2)
					.opacity(drink.drSlodycz == drSlodyczEnum.bardzoSlodki ? 1 : 0.2)
					.rotationEffect(.degrees(-20))


				RoundedRectangle(cornerRadius: 2)
					.fill(
						(
							drink.drSlodycz == drSlodyczEnum.slodki || drink.drSlodycz == drSlodyczEnum.bardzoSlodki
						) ? kolor : Color.primary
					)
					.frame(width: wielkosc, height: wielkosc * 0.2)
					.opacity((
						drink.drSlodycz == drSlodyczEnum.slodki || drink.drSlodycz == drSlodyczEnum.bardzoSlodki
					) ? 1 : 0.2)
					.rotationEffect(.degrees(-20))


				RoundedRectangle(cornerRadius: 2)
					.fill(drink.drSlodycz != drSlodyczEnum.nieSlodki ? kolor : Color.primary)
					.frame(width: wielkosc, height: wielkosc * 0.2)
					.opacity(drink.drSlodycz != drSlodyczEnum.nieSlodki ? 1 : 0.2)
					.rotationEffect(.degrees(-20))
				
				Spacer()

				if etykieta {
					Text("\(drink.drSlodycz.rawValue)".uppercased())
						.font(.caption2)
						.padding(.top, 8)
				}
			}
		}
	}
}

#Preview {
	NavigationStack {
		DrinkSkala_V(drink: drMock())
	}
}
