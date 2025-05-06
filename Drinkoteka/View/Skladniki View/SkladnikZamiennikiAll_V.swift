import SwiftData
import SwiftUI

struct SkladnikZamiennikiAll_V: View {
	@Bindable var skladnik: Skl_M
	@Environment(\.modelContext) private var modelContext
	@Query private var relacjaZamiennikow: [SklZamiennik_M]

	var zamiennikiSkladnika: [Skl_M] {
		relacjaZamiennikow
			.filter { $0.skladnikZ.id == skladnik.id }
			.map { $0.zamiennikZ }
	}

	var body: some View {
		ZStack {
			VStack(alignment: .leading) {
					// MARK: NAGŁOWEK
				HStack(alignment: .firstTextBaseline) {
					Text("Zamienniki:".uppercased())
						.TitleStyle()
					Spacer()
				}

					// MARK: LISTA ZAMIENNIKÓW
				if zamiennikiSkladnika.isEmpty {
					Text("Brak zamienników")
						.foregroundStyle(.secondary)
				} else {
					ForEach(zamiennikiSkladnika) { zamiennik in
						NavigationLink(destination: Skladnik_V(skladnik: zamiennik)) {
							SkladnikZamiennikLinia_V(skladnik: zamiennik)
						}
					}
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
		}
		.padding(20)
		.background(RoundedRectangle(cornerRadius: 12)
			.foregroundStyle(.regularMaterial))
	}
}

#Preview {
	NavigationStack {
		SkladnikZamiennikiAll_V(skladnik: sklMock())
	}
}

