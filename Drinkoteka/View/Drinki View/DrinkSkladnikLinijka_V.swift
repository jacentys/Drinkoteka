import SwiftData
import SwiftUI

struct DrinkSkladnikLinijka_V: View {
	@Bindable var drSkladnik: DrSkladnik_M
	
	var body: some View {
		HStack {
				// MARK: Kółeczko
//			IkonaJestBrak_V(
//				skladnik: skladnik,
//				wielkosc: 17)
			
				// MARK: Prostokąt przed tekstem
			Rectangle()
				.frame(width: 5, height: 15)
				.cornerRadius(2)
//				.foregroundColor(skladnik.getColor())
			
				// MARK: Nazwa składnika i informacja
			if !(drSkladnik.sklIlosc == 0) {
				Text("\(drSkladnik.skladnikID) \(drSkladnik.sklInfo) \(formatNumber(drSkladnik.sklIlosc)) \(miaraOdm(drSkladnik.sklMiara, ilosc: String(drSkladnik.sklIlosc)))")
					.fontWeight(.light)
					.multilineTextAlignment(.leading)
//					.foregroundColor(skladnik.sklStan.stan ? Color.primary : Color.secondary)
			} else {
				Text("\(drSkladnik.skladnikID ) \(drSkladnik.sklInfo)")
					.fontWeight(.light)
					.multilineTextAlignment(.leading)
//					.foregroundColor(skladnik.sklStan.stan ? Color.primary : Color.secondary)
			}
			
			
			Spacer()
			
				// MARK: Opcje
			if drSkladnik.sklOpcja {
				Text("opcj.".uppercased())
					.foregroundColor(Color.secondary)
					.font(.caption)
			}
			
				// MARK: Prostokąt na końcu
			Rectangle()
				.frame(width: 5, height: 15)
				.cornerRadius(2)
//				.foregroundColor(skladnik.getColor())
		}
	}
}

#Preview {
		//	@Previewable var drink = DrClass(sklClass: SklClass(), pref: PrefClass()).mock()
	NavigationStack{
		Text("test")
			//		DrinkSkladnikView(skladnikDr: drink.drSklad[1])
			//		DrinkSkladnikView(skladnikDr: drink.drSklad[2])
			//		DrinkSkladnikView(skladnikDr: drink.drSklad[3])
	}
	.modelContainer(for: Dr_M.self, inMemory: true)
	
}
