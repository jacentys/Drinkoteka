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
					
						// MARK: LINK
					if let url = URL(string: drink.drWWW) {
						Link(drink.drWWW, destination: url)
							.frame(maxWidth: .infinity)
							.font(.footnote)
							.fontWeight(.light)
							.multilineTextAlignment(.leading)
							.foregroundStyle(.accent)
					} else {
						Text("Problem z linkiem: \(drink.drWWW)")
					}
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
		DrinkWWW_V(drink: drMock())
	}
}
