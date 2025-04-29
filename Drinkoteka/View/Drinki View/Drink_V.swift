import SwiftData
import SwiftUI

struct Drink_V: View {
	
	@Bindable var drink: Dr_M
	
	var body: some View {
			ZStack {
				
				DrinkBack_V(drink: drink)

				ScrollView { // Główny
					
					VStack(spacing: 12) {
						DrinkTitle_V(drink: drink) // NAZWA DRINKA
						DrinkFoto_V(drink: drink) // FOTOGRAFIA
						DrinkDane_V(drink: drink) // DANE
						DrinkNotatka_V(drink: drink) // NOTATKA
						DrinkSkladniki_V(drink: drink) // SKŁAD
						DrinkPrzepis_V(drink: drink) // PRZEPIS
						DrinkWWW_V(drink: drink) // WWW
					}
					.padding(.vertical, 30)
				}
				.padding(.horizontal, 20)
			}
//			.navigationTitle("\(drink.drNazwa), \(drink.drProc)%, \(drink.drKalorie)kCal")
	}
}

#Preview {
	NavigationStack{
		Text("Test Drink V")
		Drink_V(drink: drMock())
	}
}
