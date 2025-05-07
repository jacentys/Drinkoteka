import SwiftUI

struct SkladnikZamiennikLinia_V: View {
	@Bindable var skladnik: Skl_M

	var body: some View {
		HStack {
			IkonaJestBrak_V(
				skladnik: skladnik,
				wlaczTrybZamiennikow: false
			)
			Text("\(skladnik.sklNazwa)")
				.foregroundStyle(skladnik.sklIkonaZ.stan ? Color.primary : Color.secondary)
		}
	}
}

#Preview {
	NavigationStack {
		SkladnikZamiennikLinia_V(skladnik: sklMock())
	}
}

