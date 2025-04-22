import SwiftData
import SwiftUI

struct DrinkView: View {

	@Query private var drinki: [Drink]
	@Query private var skladniki: [Skladnik]

	@EnvironmentObject var pref: PrefClass
	@EnvironmentObject var drinkiClass: DrClass
	@EnvironmentObject var skladnikiClass: SklClass
	
	@State var drSelID: String?
	
	var body: some View {
		
			// Wyciągnięcie danych  za pomocą if let i first
		if let drink = drinki.first(where: { $0.id == drSelID })
		{
			
			
			ZStack {
				
				BackgroundView(foto: drink.drFoto, kolor: drink.getKolor())

				ScrollView { // Główny
					
					VStack(spacing: 12) {
// MARK: NAZWA DRINKA
						TitleView(
							nazwa: drink.drNazwa,
							proc: drink.drProc,
							kal: drink.drKalorie,
							miara: miaraEnum.brak,
							kat: drink.drKat.rawValue
						)

						Text("\(drink.drAlkGlowny)")
						Text("\(drink.drZrodlo)")

						DrinkFotoView(drink: drink) // FOTOGRAFIA
						DrinkDaneView(drSelID: drink.id) // DANE
//						DrinkNotatka(drSelID: drink.id) // NOTATKA
						DrinkSkladnikiView(drSelID: drink.id) // SKŁAD
						DrinkPrzepisView(drSelID: drink.id) // PRZEPIS
						Text("\(drink.drWWW)")
							.padding(.bottom, 30)
					}
				}
				.padding(.horizontal, 10)
			}
//			.navigationTitle("\(drink.drNazwa), \(drink.drProc)%, \(drink.drKalorie)kCal")
		} else {
			Text("Nie znaleziono.")
		}
	}
}

#Preview {
	@Previewable var drink = DrClass(sklClass: SklClass(), pref: PrefClass()).mock()
	
	NavigationStack{
		DrinkView(drSelID: drink.id)
	}
	.environmentObject(SklClass())
	.environmentObject(DrClass(sklClass: SklClass(), pref: PrefClass()))
	.environmentObject(PrefClass())
}
