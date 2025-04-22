import SwiftUI

struct SkladnikZamiennikLinia_V: View {

	@Bindable var skladnik: Skl_M

	var body: some View {
		HStack {
			IkonaJestBrak_V(
				skladnik: skladnik,
				wyłączTrybZamiennikow: false
			)
			Text("\(skladnik.sklNazwa)")
				.foregroundStyle(skladnik.sklStan.stan ? Color.primary : Color.secondary)
		}
	}
}

#Preview {
	NavigationStack {
		Text("test")
//		SkladnikZamiennikiView(sklSelID: skladnik.id)
	}
}

