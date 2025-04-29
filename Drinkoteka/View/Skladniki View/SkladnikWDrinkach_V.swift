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
			Text("Składnik użyty w drinkach:")
				.TitleStyle()
			ForEach(skladnikiWDrinku) { drink in
				HStack {
					Text("\(drink.drNazwa)")
						.font(.headline)
					Spacer()
				}
				.padding(.horizontal, 16)
			}
		}
	}
}

#Preview {
	SkladnikWDrinkach_V(skladnik: sklMock())
}
