import SwiftUI

struct SkladnikWWW_V: View {
	@Bindable var skladnik: Skl_M

	var body: some View {
		if skladnik.sklWWW.trimmingCharacters(in: .newlines) != "" {
			ZStack {
				
				VStack(alignment: .leading) {
					
						// MARK: Nagłówek
					HStack(alignment: .firstTextBaseline) {
						Text("Strona WWW:".uppercased())
							.TitleStyle()
						Spacer()
					}
					
						// MARK: TEKST NOTATKI
					Text("\(skladnik.sklWWW)")
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
