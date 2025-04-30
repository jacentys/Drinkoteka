import SwiftUI

struct Skladnik_V: View {
	@Bindable var skladnik: Skl_M
	@State var showEdycja: Bool = false

	var body: some View {
		ZStack {
				// MARK: Background
			SkladnikiBack_V(skladnik: skladnik)
				// MARK: Data
			ScrollView { // Główny
				VStack(spacing: 12) {
					SkladnikTitle_V(skladnik:  skladnik)
					SkladnikFoto_V(skladnik: skladnik) // MARK: FOTO
					if skladnik.zamienniki.count != 0 { // MARK: ZAMIENNIKI
						SkladnikZamiennikiAll_V(skladnik: skladnik)
					}
					SkladnikOpis_V(skladnik: skladnik)
					SkladnikWWW_V(skladnik: skladnik)
					SkladnikWDrinkach_V(skladnik: skladnik)
				}
				.padding(.vertical, 30)
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
		Skladnik_V(skladnik: sklMock())
	}
}
