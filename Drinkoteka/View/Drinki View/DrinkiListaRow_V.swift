import SwiftData
import SwiftUI

struct DrinkiListaRow_V: View {
	@Bindable var drink: Dr_M
	
	var body: some View {
		NavigationLink(destination: Drink_V(drink: drink)) {
			
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
//								Text("\(drink.getSilaDrinka())")
//									.foregroundColor(Color.secondary)
//									.font(.footnote)
							}
							Spacer()
						}
						Spacer()
					}
					.frame(width: 180)
					Spacer()
					
					VStack {
						DrinkSkala_V(drink: drink, wielkosc: 20, etykieta: false)
					}
					
					Image(systemName: drink.drUlubiony ? "star.fill" : "star")
						.font(.system(size: 23))
						.foregroundStyle(drink.drUlubiony ? Color.accent : Color.gray)
//						.onTapGesture {
//							drinkiClass.updateDrinkUlubiony(drink: drink)
//						}
				}
				.padding(.horizontal, 16)
			}
		}
	}
}


#Preview {
	NavigationStack {
//		DrinkiListaRowView(drSelID: "jacuzi")
//			.preferredColorScheme(.light)
	}
}
