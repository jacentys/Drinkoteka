import SwiftUI

struct Skladnik_V: View {
	
	@State var skladnik: Skl_M
	@State var showEdycja: Bool = false

	var body: some View {

			// Wyciągnięcie danych  za pomocą if let i first
		ZStack {
				// MARK: Background
			Background_V(foto: skladnik.sklFoto, kolor: skladnik.getColor())
				// MARK: Data
			ScrollView { // Główny
				VStack(spacing: 12) {
//					TitleView(nazwa: skladnik.sklNazwa, proc: skladnik.sklProc, kal: skladnik.sklKal, miara: skladnik.sklMiara, kat: skladnik.sklKat.rawValue)

						// MARK: NAZWA

					SkladnikFoto_V(skladnik: skladnik) // MARK: FOTO

					if skladnik.sklZamArray.count != 0 { // MARK: ZAMIENNIKI
						SkladnikZamiennikiAll_V(skladnik: skladnik)
					}
					SkladnikOpis_V(skladnik: skladnik)
				}
			}
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					NavigationLink("Edytuj") {
//						SklEdit(sklSelID: skladnik.id)
					}
				}
			} // MARK: TOOLBAR
			.padding(.horizontal, 10)
		}
	}
}

#Preview {
	NavigationStack {
		Text("skltest")
//		SkladnikView(sklSelID: skladnik.id)
	}
}
