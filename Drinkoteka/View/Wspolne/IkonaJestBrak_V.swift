import SwiftData
import SwiftUI

struct IkonaJestBrak_V: View {
	@Environment(\.modelContext) private var modelContext
	@AppStorage("zamiennikiDozwolone") private var zamiennikiDozwolone: Bool = false
	
	@Bindable var skladnik: Skl_M // Parametr skladnika
	@State var txtShow: Bool = false // Czy pokazywać opis?
	@State var wielkosc: CGFloat = 18 // Wielkość ikonki
	@State var wyłączTrybZamiennikow: Bool = false // Jeśli true, uwzględniona jest preferencja zamiennikiDozwolone. Jeśli false, pokazuje tylko dwa stany.

	var body: some View {

		VStack {
			Image(systemName: zamiennikiOn(stan: skladnik.sklStan, pref: zamiennikiDozwolone, wyłączTrybZamiennikow).ikonka)
				.font(.system(size: wielkosc))
				.foregroundStyle(zamiennikiOn(stan: skladnik.sklStan, pref: zamiennikiDozwolone, wyłączTrybZamiennikow).kolor)
				.onTapGesture {
					skladnik.stanToggle()
					setAllBraki(modelContext: modelContext)
				}
			if txtShow {
				Text(skladnik.sklStan.opis)
					.font(.caption)
					.foregroundStyle(zamiennikiOn(stan: skladnik.sklStan, pref: zamiennikiDozwolone, wyłączTrybZamiennikow).kolor)
			}
		}
	}
}


#Preview {
	NavigationStack {
		let skl1 = Skl_M(sklID: ".absynt", sklNazwa: "Absynt", sklKat: .alkohol, sklProc: 70, sklKolor: "zielony", sklFoto: "absynt", sklStan: .brak, sklOpis: "Ziołowy likier z anyżkiem.", sklKal: 300, sklMiara: .ml, sklWWW: "https://absynt.example.com"
		)
		let skl2 = Skl_M(sklID: ".aperol", sklNazwa: "Aperol", sklKat: .alkohol, sklProc: 70, sklKolor: "zielony", sklFoto: "absynt", sklStan: .jest, sklOpis: "Ziołowy likier z anyżkiem.", sklKal: 300, sklMiara: .ml, sklWWW: "https://absynt.example.com"
		)
		let skl3 = Skl_M(sklID: ".amaretto", sklNazwa: "Amaretto", sklKat: .alkohol, sklProc: 70, sklKolor: "zielony", sklFoto: "absynt", sklStan: .zmBrak, sklOpis: "Ziołowy likier z anyżkiem.", sklKal: 300, sklMiara: .ml, sklWWW: "https://absynt.example.com"
		)
		let skl4 = Skl_M(sklID: ".bourbon", sklNazwa: "Bourbon", sklKat: .alkohol, sklProc: 70, sklKolor: "zielony", sklFoto: "absynt", sklStan: .zmJest, sklOpis: "Ziołowy likier z anyżkiem.", sklKal: 300, sklMiara: .ml, sklWWW: "https://absynt.example.com"
		)

		Text("Absynt - Brak")
		IkonaJestBrak_V(skladnik: skl1, txtShow: true)
		Text("Aperol - Jest")
		IkonaJestBrak_V(skladnik: skl2, txtShow: true)
		Text("Amaretto - Zam Brak")
		IkonaJestBrak_V(skladnik: skl3, txtShow: true)
		Text("Bourbon - Zam. Jest")
		IkonaJestBrak_V(skladnik: skl4, txtShow: true)
		Divider()
		Text("Absynt - Brak")
		IkonaJestBrak_V(skladnik: skl1, txtShow: false)
		Text("Aperol - Jest")
		IkonaJestBrak_V(skladnik: skl2, txtShow: false)
		Text("Amaretto - Zamiennik Brak")
		IkonaJestBrak_V(skladnik: skl3, txtShow: false)
		Text("Bourbon - Zamiennik Jest")
		IkonaJestBrak_V(skladnik: skl4, txtShow: false)
	}
	.modelContainer(for: Dr_M.self, inMemory: true)
	.modelContainer(for: Skl_M.self, inMemory: true)

}
