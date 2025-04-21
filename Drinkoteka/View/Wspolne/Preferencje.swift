import SwiftData
import SwiftUI

struct Preferencje: View {
	
	@Environment(\.modelContext) private var modelContext
	
	@Query(sort: [SortDescriptor(\Dr_M.drNazwa)])
	private var wszystkieDrinki: [Dr_M]
	
	@Query(sort: [SortDescriptor(\Skl_M.sklNazwa)])
	private var wszystkieSkladniki: [Skl_M]
	
	@EnvironmentObject var pref: PrefClass
	let spacje: CGFloat = 10
	
	var body: some View {
		Form {
			Section( // MARK: TYLKO KOMPLETNE
				header: Label("Dostępne", systemImage: pref.dostepne ? "checkmark.circle.fill" : "checkmark.circle")
					.font(.headline)
					.foregroundStyle(pref.dostepne ? Color.accent : Color.secondary),
				footer: Text("Pokazuj tylko drinki które mogą zostać przyrządzone z dostępnych składników.\nTa opcja ukrywa pozostałe składniki gdy nie ma wszystkich składników.\n Dwie poniższe opcje są brane pod uwagę.")) {
					Toggle(isOn: $pref.dostepne) {
						Text("Pokazuj tylko drinki dostępne")
					}
//					.onChange(of: pref.dostepne) { _, _ in
//						drinkiClass.setWszystkieBraki()
//					}
				}

			Section( // MARK: Ulubione
				header: Label("Ulubione", systemImage: pref.ulubione ? "star.circle.fill" : "star.circle")
					.font(.headline)
					.foregroundStyle(pref.ulubione ? Color.accent : Color.secondary),
				footer: Text("Pokazuj tylko drinki zaznaczone gwiazdką jako ulubione.")) {
					Toggle(isOn: $pref.ulubione) {
						Text("Pokazuj tylko ulubione")
					}
				}

			Section( // MARK: Zamienniki
				header: Label("Zamienniki", systemImage: pref.zamienniki ? "repeat.circle.fill" : "repeat.circle")
					.font(.headline)
					.foregroundStyle(pref.zamienniki ? Color.accent : Color.secondary),
				footer: Text("Jeśli zaznaczono, przy sprawdzaniu dostępności składników brane są pod uwagę zamienniki. Zwiększa to ilość możliwych do zrobienia drinków. Trzeba liczyć się z delikatną zmianą smaku w stosunku do oryginału.")) {
					Toggle(isOn: $pref.zamienniki) {
						Text("Dopuszczaj zamienniki")
					}
//					.onChange(of: pref.zamienniki) { _, _ in
//						drinkiClass.setWszystkieBraki()
//					}
				}
			
			Section( // MARK: Opcjonalne
				header: Label("Opcjonalne", systemImage: pref.opcjonalne ? "list.bullet.circle.fill" : "list.bullet.circle")
					.font(.headline)
					.foregroundStyle(pref.opcjonalne ? Color.accent : Color.secondary),
				footer: Text("Przy sprawdzaniu dostępności składników w drinku wymuszaj branie pod uwagę składników opcjonalnych. Składniki te często używane są do przyozdabiania drinków lub wzbogacania smaku.")) {
					Toggle(isOn: $pref.opcjonalne) {
						Text("Składniki opcjonalne wymagane")
					}
//					.onChange(of: pref.zamienniki) { _, _ in
//						drinkiClass.setWszystkieBraki()
//					}
				}

			Section( // MARK: Reset składników
				header: Label("Reset!!!", systemImage: pref.opcjonalne ? "exclamationmark.square.fill" : "exclamationmark.square.fill")
					.font(.headline)
					.foregroundStyle(Color.red),
				footer: Text("Resetuje stan wszystkich składników! \nOpcja przydatna gdy chcesz od nowa wprowadzić składniki do programu.").padding(.bottom, 30)) {
					Button {
//						skladnikiClass.resetAllStan()
//						drinkiClass.setWszystkieBraki()
					} label: {
						Text("Resetuj składniki")
							.foregroundStyle(Color.red)
							.font(.headline)
					}
				}
		}
		.toggleStyle(iOSCheckboxToggleStyle())
		.navigationTitle("Preferencje aplikacji")
	}
}

#Preview {
	NavigationStack{
		Preferencje()
			.modelContainer(for: Dr_M.self, inMemory: true)
			.modelContainer(for: Skl_M.self, inMemory: true)
			.environmentObject(PrefClass())

	}
}
