import SwiftData
import SwiftUI

struct preff {
	let zamienniki: Bool = false
}

struct IkonaJestBrak: View {
	
	let pref = preff()
	
	@Environment(\.modelContext) private var modelContext
	
	@Query(sort: [SortDescriptor(\Dr_M.drNazwa)])
	private var Drinki: [Dr_M]
	
	@Query(sort: [SortDescriptor(\Skl_M.sklNazwa)])
	private var Skladniki: [Skl_M]
	
	var wybranySkladnik: [Skl_M] {
		return Skladniki.filter {
			$0.sklID.localizedCaseInsensitiveContains(sklSelID)
		}
	}
	
//	@EnvironmentObject var pref: PrefClass
	
	@State var sklSelID: String = ""
	@State var txtShow: Bool = false
	@State var wielkosc: CGFloat = 18
	@State var uwzglPref: Bool = true

	var body: some View {
		if let skladnik = wybranySkladnik.first
		{
			VStack {
				Image(systemName: zamiennikiOn(stan: skladnik.sklStan, pref: pref.zamienniki, uwzglPref: uwzglPref).ikonka)
					.font(.system(size: wielkosc))
					.foregroundStyle(zamiennikiOn(stan: skladnik.sklStan, pref: pref.zamienniki, uwzglPref: uwzglPref).kolor)
					.onTapGesture {
//						skladnik.stanToggle(skl: skladnik)
//						drClass.setWszystkieBraki()
					}
					if txtShow {
						Text(skladnik.sklStan.opis)
							.font(.caption)
							.foregroundStyle(zamiennikiOn(stan: skladnik.sklStan, pref: pref.zamienniki, uwzglPref: uwzglPref).kolor)
					}
				}
		} else {
			Text("Nie stworzona zmienna skladnik w view IkonkaDost")
		}
	}

}


#Preview {
	NavigationStack {
		Text("Absynt - Brak")
		IkonaJestBrak(sklSelID: ".absynt", txtShow: true)
		Text("Aperol - Jest")
		IkonaJestBrak(sklSelID: ".aperol", txtShow: true)
		Text("Amaretto - Zamiennik Brak")
		IkonaJestBrak(sklSelID: ".amaretto", txtShow: true)
		Text("Bourbon - Zamiennik Jest")
		IkonaJestBrak(sklSelID: ".bourbon", txtShow: true)
	}
	.modelContainer(for: Dr_M.self, inMemory: true)
	.modelContainer(for: Skl_M.self, inMemory: true)

}
