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
	let spacje: CGFloat = 10
	
	var body: some View {
		NavigationStack {
			Form {
				Section( // MARK: Blokada ekranu
					header: Label("Wygaszacz ekranu", systemImage: blokujEkran ? "lightswitch.on" : "lightswitch.off")
						.font(.headline)
						.foregroundStyle(Color.secondary),
					footer: Text("Jeśli włączone, blokada ekranu jest nieaktywna.").padding(.bottom, 30)) {
						Button {
							blokujEkran.toggle()
							UIApplication.shared.isIdleTimerDisabled = blokujEkran
						} label: {
							Text(blokujEkran ? "Blokada wygaszacza aktywna" : "Blokada wygaszacza nieaktywna")
								.foregroundStyle(blokujEkran ? Color.red : Color.secondary)
								.font(.headline)
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
					header: Label("Konto", systemImage: "person.crop.circle")
						.font(.headline)
						.foregroundStyle(Color.green),
					footer: Text(auth.isLoggedIn ? "" : "Zaloguj się by mieć dostęp do większej ilości przepisów.").padding(.bottom, 30)) {
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
					header: Label("Opinia", systemImage: "bubble.left.and.text.bubble.right")
						.font(.headline)
						.foregroundStyle(Color.secondary),
					footer: Text("Podziel się opinią, zgłoś błąd lub zaproponuj nową funkcję.").padding(.bottom, 30)) {
						Button {
							pokazFeedback = true
						} label: {
							Text("Prześlij opinię o aplikacji")
								.foregroundStyle(Color.accent)
								.font(.headline)
						}
					}

				Section( // MARK: Reset składników
					header: Label("Reset!!!", systemImage: "exclamationmark.square.fill")
						.font(.headline)
						.foregroundStyle(Color.red),
					footer: Text("Resetuje stan wszystkich składników! \nOpcja przydatna gdy chcesz od nowa wprowadzić składniki do programu.").padding(.bottom, 30)) {
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
		UserDefaults.standard.set(false, forKey: "setupDone")
		delAll()
		Task {
			await ImageCache.shared.clearAll()
			await loadFromSupabase(modelContext: modelContext)
			UserDefaults.standard.set(true, forKey: "setupDone")
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
