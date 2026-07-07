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
	@State private var kodAktywacyjny: String = ""
	@State private var komunikatKodu: String? = nil
	@State private var aktywujeKod: Bool = false
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

				if auth.isLoggedIn {
					Section( // MARK: Kod aktywacyjny
						header: Label("Kod aktywacyjny", systemImage: "ticket")
							.font(.headline)
							.foregroundStyle(Color.secondary),
						footer: Text("Wpisz kod otrzymany od twórcy aplikacji, aby odblokować Premium lub dodatkowe kategorie.").padding(.bottom, 30)) {
							TextField("Wpisz kod", text: $kodAktywacyjny)
								.textInputAutocapitalization(.characters)
								.autocorrectionDisabled()
							if let k = komunikatKodu {
								Text(k)
									.font(.caption)
									.foregroundStyle(k.hasPrefix("✓") ? .green : .red)
							}
							Button {
								Task { await aktywujKod() }
							} label: {
								if aktywujeKod {
									ProgressView()
								} else {
									Text("Aktywuj")
										.foregroundStyle(Color.accent)
										.font(.headline)
								}
							}
							.disabled(kodAktywacyjny.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || aktywujeKod)
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

		// MARK: - AKTYWACJA KODU
	private func aktywujKod() async {
		aktywujeKod = true
		komunikatKodu = nil
		let wynik = await auth.redeemCode(kodAktywacyjny)
		switch wynik {
			case "ok":
				komunikatKodu = "✓ Kod aktywowany."
				kodAktywacyjny = ""
				// Dociągnij drinki odblokowanej kategorii (idempotentne)
				await loadFromSupabase(modelContext: modelContext)
				await loadNotesFromSupabase(modelContext: modelContext)
			case "invalid":       komunikatKodu = "Nieprawidłowy kod."
			case "expired":       komunikatKodu = "Kod wygasł."
			case "wrong_account": komunikatKodu = "Kod przypisany do innego konta."
			case "already_used":  komunikatKodu = "Ten kod został już przez Ciebie użyty."
			case "exhausted":     komunikatKodu = "Kod osiągnął limit użyć."
			case "not_logged_in": komunikatKodu = "Musisz być zalogowany."
			default:              komunikatKodu = "Błąd aktywacji. Spróbuj ponownie."
		}
		aktywujeKod = false
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
//		print("Funkcja delAll uruchomiona")
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
