import SwiftData
import SwiftUI

struct SkladnikWDrinkach_V: View {
	@Bindable var skladnik: Skl_M
	
	@Environment(\.modelContext) private var modelContext
	@Query(sort: \Dr_M.drNazwa) private var drinki: [Dr_M]
	
	var skladnikiWDrinku: [Dr_M] {
		drinki.filter { drink in
			drink.drSklad.contains { $0.skladnik.id == skladnik.id }
		}
	}
	
	var body: some View {
		if !skladnikiWDrinku.isEmpty {
			ZStack {
				VStack(alignment: .leading) {
					
					HStack(alignment: .firstTextBaseline) {
						Text("Składnik drinków:".uppercased())
							.TitleStyle()
						Spacer()
					}
					ForEach(skladnikiWDrinku) { drink in
						HStack {
							NavigationLink(drink.drNazwa) {
								Drink_V(drink: drink)
							}
							.foregroundStyle(Color.primary)
							
							Spacer()
						}
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
	SkladnikWDrinkach_V(skladnik: sklMock())
}
