
import SwiftData
import SwiftUI

struct DrinkPrzepisView: View {
	@Environment(\.modelContext) private var modelContext
	@State var drSelID: String

	@Query(sort: [SortDescriptor(\Dr_M.drNazwa)])
	private var Drinki: [Dr_M]
	
	var wybranyDrink: [Dr_M] {
		if drSelID.isEmpty {
			return Drinki
		} else {
			return Drinki.filter {
				$0.drNazwa.localizedCaseInsensitiveContains(drSelID)
			}
		}
	}
	
	var body: some View {
		if let drink = wybranyDrink.first
		{
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
		} else {
			Text("Nie znaleziono przepisu.")
		}
	}
}


#Preview {
	NavigationStack {
		DrinkPrzepisView(drSelID: "jacuzi")
	}
	.modelContainer(for: Dr_M.self, inMemory: true)
}
