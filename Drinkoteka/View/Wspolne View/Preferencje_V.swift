// Ustawienia: język, konto, kod aktywacyjny, opinia o aplikacji, reset składników.
import SwiftData
import SwiftUI

struct Preferencje_V: View {
	@Environment(\.modelContext) private var modelContext
	@StateObject private var auth = AuthService_VM.shared

	@Query(sort: [SortDescriptor(\Dr_M.drNazwa)])
	private var wszystkieDrinki: [Dr_M]

	@Query(sort: [SortDescriptor(\Skl_M.sklNazwa)])
	private var wszystkieSkladniki: [Skl_M]

	@AppStorage("zalogowany") var zalogowany: Bool?
	@AppStorage("uzytkownik") var uzytkownik: String?

	@AppStorage("blokujEkran") var blokujEkran: Bool = false
	@AppStorage("jezykAplikacji") var jezykAplikacji: String = {
		let kod = Locale.current.language.languageCode?.identifier ?? "en"
		return kod == "pl" ? "pl" : "en"
	}()

	@State private var pokazPotwierdzenie: Bool = false
	@State private var pokazFeedback: Bool = false
	@State private var infoEkran: Bool = false
	@State private var infoKonto: Bool = false
	@State private var infoOpinia: Bool = false
	@State private var infoReset: Bool = false
	let spacje: CGFloat = 10

		// Nagłówek sekcji z ikoną informacji + popoverem (jak w filtrach drinków)
	private func naglowek(_ tytul: LocalizedStringKey, systemImage: String, kolor: Color,
						   opis: LocalizedStringKey, pokaz: Binding<Bool>) -> some View {
		HStack {
			Label(tytul, systemImage: systemImage)
				.font(.headline)
				.foregroundStyle(kolor)
			Spacer()
			Button { pokaz.wrappedValue = true } label: {
				Image(systemName: "info.circle").foregroundStyle(.secondary)
			}
			.buttonStyle(.plain)
			.popover(isPresented: pokaz) {
				Text(opis)
					.font(.footnote)
					.frame(width: 260, alignment: .leading)
					.padding()
					.presentationCompactAdaptation(.popover)
			}
		}
	}

	var body: some View {
		NavigationStack {
			Form {
				Section( // MARK: Wygaszanie ekranu
					header: naglowek("Ekran", systemImage: "sun.max", kolor: Color.secondary,
									 opis: "Gdy włączone, ekran nie gaśnie podczas korzystania z aplikacji — przydatne przy przyrządzaniu drinka. Gdy wyłączone, obowiązuje autoblokada telefonu.",
									 pokaz: $infoEkran)) {
						Toggle(isOn: $blokujEkran) {
							Text("Nie wygaszaj ekranu")
								.font(.headline)
						}
						.toggleStyle(.switch)
						.onChange(of: blokujEkran) { _, nowy in
							UIApplication.shared.isIdleTimerDisabled = nowy
						}
					}
				
				Section( // MARK: Język
					header: Label("Język", systemImage: "globe")
						.font(.headline)
						.foregroundStyle(Color.secondary)) {
						Picker("Język aplikacji", selection: $jezykAplikacji) {
							Text("Polski").tag("pl")
							Text("English").tag("en")
						}
					}

				Section( // MARK: Konto
					header: naglowek("Konto", systemImage: "person.crop.circle", kolor: Color.green,
									 opis: "Załóż konto lub zaloguj się, aby zapisywać notatki i mieć dostęp do dodatkowych treści. Konto możesz w każdej chwili usunąć w jego szczegółach.",
									 pokaz: $infoKonto)) {
						if auth.isLoggedIn {
							NavigationLink(destination: AuthProfil_V()) {
								VStack(alignment: .leading, spacing: 2) {
									Text("Szczegóły konta")
										.foregroundStyle(Color.green)
										.font(.headline)
									Text(auth.userEmail)
										.font(.caption)
										.foregroundStyle(.secondary)
								}
							}
						} else {
							NavigationLink(destination: Logowanie_V()) {
								Text("Zarejestruj się / Zaloguj się")
									.foregroundStyle(Color.green)
									.font(.headline)
							}
						}
					}

				Section( // MARK: Informacja zwrotna
					header: naglowek("Opinia", systemImage: "bubble.left.and.text.bubble.right", kolor: Color.secondary,
									 opis: "Podziel się opinią, zgłoś błąd lub zaproponuj nową funkcję. Wiadomość trafi bezpośrednio do twórcy aplikacji.",
									 pokaz: $infoOpinia)) {
						Button {
							pokazFeedback = true
						} label: {
							Text("Prześlij opinię o aplikacji")
								.foregroundStyle(Color.accent)
								.font(.headline)
						}
					}

				Section( // MARK: Reset składników
					header: naglowek("Reset!!!", systemImage: "exclamationmark.square.fill", kolor: Color.red,
									 opis: "Resetuje stan wszystkich składników (odznacza barek). Przydatne, gdy chcesz wprowadzić składniki od nowa. Twoje własne drinki i przepisy pozostają.",
									 pokaz: $infoReset)) {
						Button {
							pokazPotwierdzenie = true
						} label: {
							Text("Resetuj składniki")
								.foregroundStyle(Color.red)
								.font(.headline)
						}
						.confirmationDialog(
							"Czy na pewno chcesz zresetować składniki?",
							isPresented: $pokazPotwierdzenie,
							titleVisibility: .visible
						) {
							Button("Resetuj", role: .destructive) { resetAll() }
							Button("Anuluj", role: .cancel) {}
						} message: {
							Text("Wszystkie zaznaczone składniki zostaną odznaczone.")
						}
					}
			}
			.toggleStyle(iOSCheckboxToggleStyle())
			.navigationTitle("Preferencje")
			.sheet(isPresented: $pokazFeedback) {
				AppFeedback_V()
			}
		}
	}

		// MARK: - RESET ALL
	private func resetAll() {
		Task {
			// Zachowaj własne drinki/składniki (reset barku ich nie kasuje, tylko czyści stany)
			let wlasne = await MainActor.run { snapshotWlasnejTresci(modelContext) }
			await MainActor.run {
				UserDefaults.standard.set(false, forKey: "setupDone")
				delAll()
			}
			await ImageCache.shared.clearAll()
			await loadFromSupabase(modelContext: modelContext)
			await MainActor.run {
				przywrocWlasnaTresc(wlasne.0, wlasne.1, resetujStan: true, ctx: modelContext)
				UserDefaults.standard.set(true, forKey: "setupDone")
			}
		}
	}

		// MARK: - DEL ALL
	private func delAll() {
		do {
			try modelContext.delete(model: Skl_M.self)
			try modelContext.delete(model: Dr_M.self)
		} catch {
			dprint("Błąd przy usuwaniu drinków: \(error)")
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
