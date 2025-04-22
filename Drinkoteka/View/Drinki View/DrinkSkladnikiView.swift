	//
	//  SkladnikiGrupaV.swift
	//  Barman
	//
	//  Created by Jacek Skrobisz on 2025.02.03.
	//

import SwiftUI

struct DrinkSkladnikiView: View {
	
	@EnvironmentObject var pref: PrefClass
	@EnvironmentObject var drClass: DrClass
	@EnvironmentObject var skClass: SklClass
	
	@State var drSelID: String?
	
	var body: some View {
		
		
			// Wyciągnięcie danych  za pomocą if let i first
		if let drink = drClass.drArray.first(where: { $0.id == drSelID })
		{
			
		ZStack {
			VStack(alignment: .leading, spacing: 2) {
				
					// MARK: Nagłówek
				HStack(alignment: .firstTextBaseline) {
					Text("Skład:".uppercased())
						.TitleStyle()

					Spacer()

				}
				
					// Linijki
				ForEach (drink.drSklad) { skladnikDrinka in
					NavigationLink(destination: SkladnikView(sklSelID: clearStr(skladnikDrinka.skladnikID))) {
						DrinkSkladnikView(skladnikDr: skladnikDrinka)
					}
				}
			}
		}
		.padding(20)
		.background(RoundedRectangle(cornerRadius: 12)
			.foregroundStyle(.regularMaterial))
		} else {
			Text("Nie znaleziono.")
		}
	}
}

#Preview {
	@Previewable var drink = DrClass(sklClass: SklClass(), pref: PrefClass()).mock()
	NavigationStack {
		DrinkSkladnikiView(drSelID: drink.id)
	}
	.environmentObject(PrefClass())
	.environmentObject(SklClass())
	.environmentObject(DrClass(sklClass: SklClass(), pref: PrefClass()))
}

