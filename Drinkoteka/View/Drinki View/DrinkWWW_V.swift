import SwiftUI

struct DrinkWWW_V: View {
	@Bindable var drink: Dr_M
	
	var body: some View {
		if drink.drWWW.trimmingCharacters(in: .newlines) != "" {
			ZStack {
				
				VStack(alignment: .leading) {
					
						// MARK: Nagłówek
					HStack(alignment: .firstTextBaseline) {
						Text("Strona WWW:".uppercased())
							.TitleStyle()
						Spacer()
					}
					
						// MARK: TEKST NOTATKI
					Text("\(drink.drWWW)")
						.frame(maxWidth: .infinity)
						.font(.title2)
						.fontWeight(.light)
						.multilineTextAlignment(.leading)
						.foregroundStyle(.accent)
				}
			}
			.padding(20)
			.background(
				RoundedRectangle(cornerRadius: 12)
					.foregroundStyle(.regularMaterial))
		}
	}
}

#Preview {
	NavigationStack {
		Text("WWW V")
			//		DrinkNotatka(drSelID: drink.id)
	}
}
