import SwiftUI

struct DrinkTitle_V: View {
	@Bindable var drink: Dr_M

	var body: some View {
		
		ZStack {
			VStack(spacing: 0) {
				VStack{
					HStack {
						Spacer()
						VStack {
							Text(drink.drNazwa)
								.font(.title)
								.fontWeight(.black)
								.foregroundColor(Color.primary)
								.multilineTextAlignment(.center)
							Text(drink.drZrodlo)
								.font(.footnote)
								.foregroundStyle(.secondary)
						}

						Spacer()
					}
				}  // MARK: NAZWA
				
				Divider().padding(4)
				
				HStack {
					Kategoria(kat: drink.drKat.rawValue)
					Proc(proc: drink.drProc)
//					Miara(miara: drink.drMiara)
				}
			}
			.shadow(color: .white, radius: 20)
		}
		.foregroundColor(Color.primary)
		.padding(20)
		.background(RoundedRectangle(cornerRadius: 12)
			.foregroundStyle(.regularMaterial)
			)
	}
}

#Preview {
	DrinkTitle_V(drink: drMock())
}
