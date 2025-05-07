import SwiftData
import SwiftUI

struct DrinkSkladnikLinijka_V: View {
	@Bindable var drSkladnik: DrSkladnik_M
	var skladnik: Skl_M { return drSkladnik.skladnik }

	var body: some View {
		HStack {
//				 MARK: Kółeczko
			IkonaJestBrak_V(
				skladnik: skladnik,
				wielkosc: 17,
				wlaczTrybZamiennikow: true)
			Text("\(drSkladnik.sklNo)")
				// MARK: Prostokąt przed tekstem
			Rectangle()
				.frame(width: 5, height: 15)
				.cornerRadius(2)
				.foregroundColor(skladnik.getKolor())
			
				// MARK: Nazwa składnika i informacja
			if !(drSkladnik.sklIlosc == 0) {
				Text("\(skladnik.sklNazwa) \(drSkladnik.sklInfo) \(formatNumber(drSkladnik.sklIlosc)) \(miaraOdm(drSkladnik.sklMiara, ilosc: String(drSkladnik.sklIlosc)))")
					.fontWeight(.light)
					.multilineTextAlignment(.leading)
					.foregroundColor(skladnik.sklIkonaZ.stan ? Color.primary : Color.secondary)
			} else {
				Text("\(skladnik.sklNazwa ) \(drSkladnik.sklInfo)")
					.fontWeight(.light)
					.multilineTextAlignment(.leading)
					.foregroundColor(skladnik.sklIkonaZ.stan ? Color.primary : Color.secondary)
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
				.foregroundColor(skladnik.getKolor())
		}
	}
}

#Preview {
	NavigationStack{
		DrinkSkladnikLinijka_V(drSkladnik: drMock().drSklad[0])
		DrinkSkladnikLinijka_V(drSkladnik: drMock().drSklad[1])
		DrinkSkladnikLinijka_V(drSkladnik: drMock().drSklad[2])
	}
}
