
import SwiftData
import SwiftUI

struct DrinkPrzepisView: View {
	@Bindable var drink: Dr_M

	var body: some View {
		ZStack {
			VStack(alignment: .leading) {

					// MARK: Nagłówek
				HStack(alignment: .firstTextBaseline) {
					Text("Przepis:".uppercased())
						.TitleStyle()

					Spacer()
				}
				ForEach(drink.drPrzepis.sorted {$0.przepNo < $1.przepNo}) { przepisLinia in
					HStack(spacing: 5) {
							// MARK: NUMERACJA
						Image(systemName: przepisLinia.przepOpcja ? "\(przepisLinia.przepNo).circle" : "\(przepisLinia.przepNo).circle.fill")
							.foregroundColor(przepisLinia.przepOpcja ? Color.secondary: Color.accent)
							.font(.headline)
							// MARK: OPIS
						Text(" \(przepisLinia.przepOpis)")
							.fontWeight(.light)
							//								.multilineTextAlignment(.leading)
							.foregroundStyle(!przepisLinia.przepOpcja ? Color.primary : Color.secondary)
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
//	NavigationStack {
	Text("Test")
//		DrinkPrzepisView(drSelID: "jacuzi")
//	}
	.modelContainer(for: Dr_M.self, inMemory: true)
}
