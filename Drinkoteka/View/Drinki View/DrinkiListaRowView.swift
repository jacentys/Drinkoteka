import SwiftData
import SwiftUI

struct DrinkiListaRowView: View {

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
			NavigationLink(destination: DrinkView(drSelID: drink.id)) {
				
				ZStack {
					Rectangle()
						.frame(maxWidth: .infinity)
						.frame(minHeight: 66)
						.foregroundStyle(.thinMaterial)
					
					HStack {
						ZStack {
							Circle()
								.fill(.regularMaterial.opacity(drink.drBrakuje == 0 ? 0.8 : 0.8))
								.stroke(drink.getKolor().opacity(drink.drBrakuje == 0 ? 0.8 : 0.8), lineWidth: drink.drBrakuje == 0 ? 1 : 1)

							Image(!drink.drFoto.isEmpty ? drink.drFoto :  drink.drSzklo.foto)
								.resizable()
								.aspectRatio(contentMode: .fit)
								.frame(width: 35, height: 35)
								.foregroundStyle(Color.primary)
							
							Image(systemName: "checkmark")
								.font(.system(size: 12))
								.fontWeight(.black)
								.frame(width: 60, height: 50, alignment: .bottomTrailing)
								.foregroundStyle(Color.primary.opacity(drink.drBrakuje == 0 ? 1 : 0))
						}
						.frame(width: 60, height: 50)

						Divider()

						VStack {
							Spacer()
							
							HStack(spacing: 0) {
								VStack(alignment: .leading) {
										Text("\(drink.drNazwa)")
											.font(.headline)
											.foregroundStyle(Color.primary)
									Text("\(drink.getSilaDrinka())")
										.foregroundColor(Color.secondary)
										.font(.footnote)
								}
								Spacer()
							}
							Spacer()
						}
						.frame(width: 180)
						Spacer()

						VStack {
							DrinkSkalaView(slodycz: drink.drSlodycz, wielkosc: 20, etykieta: false)
						}
						
						Image(systemName: drink.drUlubiony ? "star.fill" : "star")
							.font(.system(size: 23))
							.foregroundStyle(drink.drUlubiony ? Color.accent : Color.gray)
							.onTapGesture {
								drinkiClass.updateDrinkUlubiony(drink: drink)
							}
					}
					.padding(.horizontal, 16)
				}
			}
		} else {
			Text("Nie znaleziono.")
		}
	}
}


#Preview {
	@Previewable var drink = DrClass(sklClass: SklClass(), pref: PrefClass()).mock()

		NavigationStack {
			DrinkiListaRowView(drSelID: "jacuzi")
				.preferredColorScheme(.light)
		}
	.environmentObject(SklClass())
	.environmentObject(DrClass(sklClass: SklClass(), pref: PrefClass()))
	.environmentObject(PrefClass())
}
