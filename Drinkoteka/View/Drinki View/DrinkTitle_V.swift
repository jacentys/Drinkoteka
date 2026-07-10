import SwiftUI

struct DrinkTitle_V: View {
	@Bindable var drink: Dr_M
	@StateObject private var auth = AuthService_VM.shared
	@State private var pokazEdycje = false

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
							Text(LocalizedStringKey(drink.drZrodlo))
								.font(.footnote)
								.foregroundStyle(.secondary)
						}

						Spacer()

						// Edycja pól: admin — wszystkie drinki; premium — tylko własne
						if auth.mozeEdytowac(drink) {
							Button {
								pokazEdycje = true
							} label: {
								Image(systemName: "pencil.circle")
									.font(.title3)
									.foregroundStyle(.secondary)
							}
						}
					}
				}  // MARK: NAZWA
				
				Divider().padding(4)
				
				HStack {
					viewKategoria(kat: drink.drKat.opis)
					viewProcenty(proc: drink.drProc)
				}
			}
			.shadow(color: .white, radius: 20)
		}
		.foregroundColor(Color.primary)
		.padding(20)
		.background(RoundedRectangle(cornerRadius: 12)
			.foregroundStyle(.regularMaterial)
			)
		.sheet(isPresented: $pokazEdycje) {
			DrinkPolaEdycja_V(drink: drink)
		}
	}
}

#Preview {
	DrinkTitle_V(drink: drMock())
}
