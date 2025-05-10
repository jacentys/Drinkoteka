
import SwiftData
import SwiftUI

struct DrinkPrzepis_V: View {
	@Bindable var drink: Dr_M
	@State var edycjaOn: Bool = false
	
	var body: some View {
		ZStack {
			VStack(alignment: .leading) {
				
					// MARK: Nagłówek
				HStack(alignment: .firstTextBaseline) {
					Text("Przepis:".uppercased())
						.TitleStyle()
					
					Spacer()
					
					Button {
						edycjaOn.toggle()
					} label: {
						Text(!edycjaOn ? "Edytuj" : "Zakończ")
					}
				}
				ForEach(drink.drPrzepis.sorted {$0.przepNo < $1.przepNo}) { przepisLinia in
					
					@Bindable var skladniczek = przepisLinia
					
					HStack(spacing: 5) {
							// MARK: NUMERACJA
						Image(systemName: przepisLinia.przepOpcja ? "\(przepisLinia.przepNo).circle" : "\(przepisLinia.przepNo).circle.fill")
							.foregroundColor(przepisLinia.przepOpcja ? Color.secondary: Color.accent)
							.font(.headline)
						
							// MARK: OPIS
						HStack(spacing: 0) {
							TextEditor(text: $skladniczek.przepOpis)
								.fontWeight(.light)
								.scrollContentBackground(.hidden)
								.multilineTextAlignment(.leading)
								.foregroundStyle(Color.primary)
								.disabled(!edycjaOn)
								.padding(.trailing, edycjaOn ? 0 : -6)
								.padding(.vertical, edycjaOn ? 0 : -6)
								.background(Color.primary.opacity(edycjaOn ? 0.2 : 0))
						}
						Spacer()
					}
					.padding(.vertical, 2)
				}
				if (!drink.drUwagi.isEmpty) {
					Divider()
					Text("\(drink.drUwagi)")
				}
			}
		}
		.padding(20)
		.background(
			RoundedRectangle(cornerRadius: 12)
				.foregroundStyle(.regularMaterial))
	}
}


#Preview {
	DrinkPrzepis_V(drink: drMock())
}

