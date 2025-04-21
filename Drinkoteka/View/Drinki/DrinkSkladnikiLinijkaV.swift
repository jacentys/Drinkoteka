import SwiftData
//import Foundation
import SwiftUI

struct DrinkSkladnikView: View {

	@Environment(\.modelContext) private var modelContext
	
	@Query(sort: [SortDescriptor(\Skl_M.sklNazwa)])
	private var Skladniki: [Skl_M]
	
	var wybranySkladnik: [Skl_M] {
		return Skladniki.filter {
			$0.sklID.localizedCaseInsensitiveContains(skladnikDr.skladnikID)
		}
	}

	@State var skladnikDr: DrSkladnik_M
	
	var body: some View {
		if let skladnik = wybranySkladnik.first {
		{
			HStack {
					// MARK: Kółeczko
				IkonaJestBrak(
					sklSelID: skladnik.id,
					wielkosc: 17)

					// MARK: Prostokąt przed tekstem
				Rectangle()
					.frame(width: 5, height: 15)
					.cornerRadius(2)
					.foregroundColor(skladnik.getColor())

					// MARK: Nazwa składnika i informacja
				if !(skladnikDr.sklIlosc == 0) {
					Text("\(skladnik.sklNazwa ) \(skladnikDr.sklInfo) \(formatNumber(skladnikDr.sklIlosc)) \(miara(miara: skladnikDr.sklMiara, ilosc: String(skladnikDr.sklIlosc)))")
					.fontWeight(.light)
					.multilineTextAlignment(.leading)
					.foregroundColor(skladnik.sklStan.stan ? Color.primary : Color.secondary)
				} else {
					Text("\(skladnik.sklNazwa ) \(skladnikDr.sklInfo)")
					.fontWeight(.light)
					.multilineTextAlignment(.leading)
					.foregroundColor(skladnik.sklStan.stan ? Color.primary : Color.secondary)
				}
									

				Spacer()
				
				// MARK: Opcje
				if skladnikDr.sklOpcja {
					Text("opcj.".uppercased())
						.foregroundColor(Color.secondary)
						.font(.caption)
				}
				
					// MARK: Prostokąt na końcu
				Rectangle()
					.frame(width: 5, height: 15)
					.cornerRadius(2)
					.foregroundColor(sklClass.getSklFromID(sklID: skladnikDr.skladnikID).getColor())
			}
		} else {
			Text("Nie znaleziono skladnika.")
		}
	}
}

#Preview {
	@Previewable var drink = DrClass(sklClass: SklClass(), pref: PrefClass()).mock()
	NavigationStack{
		DrinkSkladnikView(skladnikDr: drink.drSklad[1])
		DrinkSkladnikView(skladnikDr: drink.drSklad[2])
		DrinkSkladnikView(skladnikDr: drink.drSklad[3])
	}
	.environmentObject(PrefClass())
	.environmentObject(SklClass())
	.environmentObject(DrClass(sklClass: SklClass(), pref: PrefClass()))
}
