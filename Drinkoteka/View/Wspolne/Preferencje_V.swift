import SwiftData
import SwiftUI

struct Preferencje_V: View {
	@Environment(\.modelContext) private var modelContext

	@Query(sort: [SortDescriptor(\Dr_M.drNazwa)])
	private var wszystkieDrinki: [Dr_M]

	@Query(sort: [SortDescriptor(\Skl_M.sklNazwa)])
	private var wszystkieSkladniki: [Skl_M]

	@AppStorage("zalogowany") var zalogowany: Bool?
	@AppStorage("uzytkownik") var uzytkownik: String?

	@AppStorage("opcjonalneWymagane") var opcjonalneWymagane: Bool = false
	@AppStorage("zamiennikiDozwolone") var zamiennikiDozwolone: Bool = false
	@AppStorage("tylkoUlubione") var tylkoUlubione: Bool = false
	@AppStorage("tylkoDostepne") var tylkoDostepne: Bool = false

	let spacje: CGFloat = 10
	
	var body: some View {
		NavigationStack {
			Form {
				Section( // MARK: TYLKO KOMPLETNE
					header: Label("Dostępne", systemImage: tylkoDostepne ? "checkmark.circle.fill" : "checkmark.circle")
						.font(.headline)
						.foregroundStyle(tylkoDostepne ? Color.accent : Color.secondary),
					footer: Text("Pokazuj tylko drinki które mogą zostać przyrządzone z dostępnych składników.\nTa opcja ukrywa pozostałe składniki gdy nie ma wszystkich składników.\n Dwie poniższe opcje są brane pod uwagę.")) {
						Toggle(isOn: $tylkoDostepne) {
							Text("Pokazuj tylko drinki dostępne")
						}
							//					.onChange(of: tylkoDostepne) { _, _ in
							//						drinkiClass.setWszystkieBraki()
							//					}
					}

				Section( // MARK: Ulubione
					header: Label("Ulubione", systemImage: tylkoUlubione ? "star.circle.fill" : "star.circle")
						.font(.headline)
						.foregroundStyle(tylkoUlubione ? Color.accent : Color.secondary),
					footer: Text("Pokazuj tylko drinki zaznaczone gwiazdką jako ulubione.")) {
						Toggle(isOn: $tylkoUlubione) {
							Text("Pokazuj tylko ulubione")
						}
					}

				Section( // MARK: Zamienniki
					header: Label("Zamienniki", systemImage: zamiennikiDozwolone ? "repeat.circle.fill" : "repeat.circle")
						.font(.headline)
						.foregroundStyle(zamiennikiDozwolone ? Color.accent : Color.secondary),
					footer: Text("Jeśli zaznaczono, przy sprawdzaniu dostępności składników brane są pod uwagę zamienniki. Zwiększa to ilość możliwych do zrobienia drinków. Trzeba liczyć się z delikatną zmianą smaku w stosunku do oryginału.")) {
						Toggle(isOn: $zamiennikiDozwolone) {
							Text("Dopuszczaj zamienniki")
						}
							//					.onChange(of: zamiennikiDozwolone) { _, _ in
							//						drinkiClass.setWszystkieBraki()
							//					}
					}

				Section( // MARK: Opcjonalne
					header: Label("Opcjonalne", systemImage: opcjonalneWymagane ? "list.bullet.circle.fill" : "list.bullet.circle")
						.font(.headline)
						.foregroundStyle(opcjonalneWymagane ? Color.accent : Color.secondary),
					footer: Text("Przy sprawdzaniu dostępności składników w drinku wymuszaj branie pod uwagę składników opcjonalnych. Składniki te często używane są do przyozdabiania drinków lub wzbogacania smaku.")) {
						Toggle(isOn: $opcjonalneWymagane) {
							Text("Składniki opcjonalne wymagane")
						}
							//					.onChange(of: zamiennikiDozwolone) { _, _ in
							//						drinkiClass.setWszystkieBraki()
							//					}
					}

				Section( // MARK: Reset składników
					header: Label("Reset!!!", systemImage: opcjonalneWymagane ? "exclamationmark.square.fill" : "exclamationmark.square.fill")
						.font(.headline)
						.foregroundStyle(Color.red),
					footer: Text("Resetuje stan wszystkich składników! \nOpcja przydatna gdy chcesz od nowa wprowadzić składniki do programu.").padding(.bottom, 30)) {
						Button {
							resetAll()
								//						drinkiClass.setWszystkieBraki()
						} label: {
							Text("Resetuj składniki")
								.foregroundStyle(Color.red)
								.font(.headline)
						}
					}
			}
			.toggleStyle(iOSCheckboxToggleStyle())
			.navigationTitle("Preferencje")
		}
	}

		// MARK: - RESET ALL
	private func resetAll() {
		print("Startuje resetAll, setupDone: \(UserDefaults.standard.bool(forKey: "setupDone"))")
		UserDefaults.standard.set(false, forKey: "setupDone")
		print("Zmiana wartości resetAll, setupDone: \(UserDefaults.standard.bool(forKey: "setupDone"))")
			//							debugPobrane(miejsce: "Przed")
		delAll()
		loadSklCSV_V(modelContext: modelContext)
		loadSklZamiennikiCSV_V(modelContext: modelContext)
		loadDrCSV_V(modelContext: modelContext)
		loadDrSkladnikiCSV_V(modelContext: modelContext)
		loadDrAlkGlownyCSV_V(modelContext: modelContext)
		loadDrPrzepisyCSV_V(modelContext: modelContext)
		try? modelContext.save()
			//							debugPobrane(miejsce: "Po")
		UserDefaults.standard.set(true, forKey: "setupDone")
		print("Koniec resetAll, setupDone: \(UserDefaults.standard.bool(forKey: "setupDone"))")
	}

		// MARK: - DEL ALL
	private func delAll() {
		print("Funkcja delAll uruchomiona")
		do {
			try modelContext.delete(model: Skl_M.self)
			try modelContext.delete(model: Dr_M.self)
		} catch {
			print("Błąd przy usuwaniu drinków: \(error)")
		}
	}
}

#Preview {
	NavigationStack{
		Preferencje_V()
			.modelContainer(for: Dr_M.self, inMemory: true)
			.modelContainer(for: Skl_M.self, inMemory: true)
	}
}
