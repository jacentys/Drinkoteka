import SwiftData
import SwiftUI

struct DrinkSkladniki_V: View {

	@Bindable var drink: Dr_M
	@Environment(\.modelContext) private var modelContext
	@StateObject private var auth = AuthService_VM.shared
	@Query(sort: \Skl_M.sklNazwa) private var wszystkieSkladniki: [Skl_M]

	@State private var isEditing = false
	@State private var pokazWyborSkladnika = false

	var body: some View {
		ZStack {
			VStack(alignment: .leading, spacing: 2) {

					// MARK: Nagłówek
				HStack(alignment: .firstTextBaseline) {
					Text("Skład:")
						.TitleStyle()
						.textCase(.uppercase)
					Spacer()

						// Edycja: admin — wszystkie drinki; premium — tylko własne
					if auth.mozeEdytowac(drink) {
						Button(action: {
							let konczeEdycje = isEditing
							withAnimation {
								isEditing.toggle()
							}
							guard konczeEdycje else { return }
							// Ilość/miara mogły się zmienić bezpośrednio w polach —
							// zawsze przelicz moc/kalorie po zakończeniu edycji.
							przeliczMocIKalorie(drink)
							// Admin edytujący treść serwerową → wypchnij na serwer
							if auth.isAdmin && drink.drZrodlo != "Własny" {
								Task { await pushSkladnikiAdmin(drink: drink) }
							}
						}) {
							Text(isEditing ? "Gotowe" : "Edytuj")
						}
					}
				}

					// Linijki
				ForEach (drink.drSklad.sorted(by: { $0.sklNo < $1.sklNo })) { skladnikDrinka in
					if isEditing {
						DrinkSkladnikLinijkaE_V(drSkladnik: skladnikDrinka) {
							usunSkladnik(skladnikDrinka)
						}
					} else {
						NavigationLink(
							destination: Skladnik_V(skladnik: skladnikDrinka.skladnik)) {
								DrinkSkladnikLinijka_V(drSkladnik: skladnikDrinka)
							}
					}
				}

				if isEditing {
					Button {
						pokazWyborSkladnika = true
					} label: {
						Label("Dodaj składnik", systemImage: "plus.circle.fill")
					}
					.padding(.top, 6)
				}
			}
		}
		.padding(20)
		.background(RoundedRectangle(cornerRadius: 12)
			.foregroundStyle(.regularMaterial))
		.sheet(isPresented: $pokazWyborSkladnika) {
			// Admin edytujący katalog może wybrać tylko składniki obecne na serwerze
			// (własne lokalne składniki nie istnieją w bazie — naruszyłoby to FK).
			let doKatalog = auth.isAdmin && drink.drZrodlo != "Własny"
			let dostepne = doKatalog ? wszystkieSkladniki.filter { !$0.sklWlasny } : wszystkieSkladniki
			WyborSkladnika_V(wszystkie: dostepne, dozwolNowy: !doKatalog) { wybrany in
				dodajSkladnik(wybrany)
			}
		}
	}

		// MARK: - Dodawanie składnika
	private func dodajSkladnik(_ skladnik: Skl_M) {
		let nowy = DrSkladnik_M(
			relacjaDrink: drink,
			skladnik: skladnik,
			sklNo: drink.drSklad.count + 1,
			sklIlosc: 0
		)
		modelContext.insert(nowy)
		przeliczMocIKalorie(drink)
	}

		// MARK: - Usuwanie składnika
	private func usunSkladnik(_ pozycja: DrSkladnik_M) {
		modelContext.delete(pozycja)
		let pozostale = drink.drSklad.sorted { $0.sklNo < $1.sklNo }
		for (i, p) in pozostale.enumerated() { p.sklNo = i + 1 }
		przeliczMocIKalorie(drink)
	}
}

#Preview {
	NavigationStack {
		DrinkSkladniki_V(drink: drMock())
	}
}

