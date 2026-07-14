import SwiftUI

struct Skladnik_V: View {
	@Bindable var skladnik: Skl_M
	@State var showEdycja: Bool = false
	@State private var pokazTytulWNav: Bool = false

	var body: some View {
		ZStack {
				// MARK: Background
			SkladnikiBack_V(skladnik: skladnik)
				// MARK: Data
			ScrollView { // Główny
				VStack(spacing: 12) {
					SkladnikTitle_V(skladnik:  skladnik)
						.onGeometryChange(for: CGFloat.self) { geo in
							geo.frame(in: .named("skladnikScroll")).maxY
						} action: { maxY in
							withAnimation(.easeInOut(duration: 0.2)) {
								pokazTytulWNav = maxY < 0
							}
						}
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
			.coordinateSpace(name: "skladnikScroll")
			.safeAreaInset(edge: .bottom) {
				Color.clear.frame(height: 30)
			}
			.toolbar {
				// Ten sam styl tytułu, co "Drinkotheque" na ekranie głównym — pokazywany
				// dopiero gdy SkladnikTitle_V w treści zniknie pod górną krawędzią.
				ToolbarItem(placement: .principal) {
					Text(skladnik.sklNazwa)
						.font(.largeTitle)
						.fontWeight(.light)
						.foregroundStyle(Color.primary)
						.shadow(color: .black.opacity(0.6), radius: 6)
						.lineLimit(1)
						.opacity(pokazTytulWNav ? 1 : 0)
				}
				ToolbarItem(placement: .confirmationAction) {
					NavigationLink("Edytuj") {
					}
				}
			} // MARK: TOOLBAR
			.navigationBarTitleDisplayMode(.inline)
			.toolbarBackground(.visible, for: .navigationBar)
			.toolbarBackground(Material.thickMaterial, for: .navigationBar)
			.padding(.horizontal, 10)
		}
	}
}

#Preview {
	NavigationStack {
		Skladnik_V(skladnik: sklMock())
	}
}
