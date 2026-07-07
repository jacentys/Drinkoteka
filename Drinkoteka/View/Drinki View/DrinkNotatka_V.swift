// Notatka do drinka (funkcja Premium). Edytor + ekran informacji o Premium (odblokowanie kodem).
import SwiftUI

struct DrinkNotatka_V: View {
	@Bindable var drink: Dr_M
	@StateObject private var auth = AuthService_VM.shared
	@State private var pokazEdytor: Bool = false
	@State private var pokazPremiumInfo: Bool = false

	var body: some View {
		if drink.drNotatka.isEmpty {
			Button {
				if auth.isPremium {
					pokazEdytor = true
				} else {
					pokazPremiumInfo = true
				}
			} label: {
				Text("Dodaj Notatkę")
					.font(.headline)
					.frame(maxWidth: .infinity)
					.frame(height: 54)
					.foregroundColor(Color.white)
					.background(auth.isPremium ? Color.accent : Color.secondary)
					.cornerRadius(8)
			}
			.sheet(isPresented: $pokazEdytor) {
				NotatkaEdytor_V(drink: drink)
			}
			.sheet(isPresented: $pokazPremiumInfo) {
				PremiumInfo_V()
			}
		} else {
			ZStack {
				VStack(alignment: .leading, spacing: 8) {
					HStack(alignment: .firstTextBaseline) {
						Text("Notatka:")
							.TitleStyle()
							.textCase(.uppercase)
						Spacer()
						Button {
							pokazEdytor = true
						} label: {
							Text("Edytuj notatkę")
								.font(.caption)
								.foregroundStyle(Color.accent)
						}
						.sheet(isPresented: $pokazEdytor) {
							NotatkaEdytor_V(drink: drink)
						}
					}

					Text(drink.drNotatka)
						.fontWeight(.light)
						.multilineTextAlignment(.leading)
				}
				.padding(20)
				.background(
					RoundedRectangle(cornerRadius: 12)
						.foregroundStyle(.regularMaterial))
			}
		}
	}
}

// MARK: - EDYTOR NOTATKI

struct NotatkaEdytor_V: View {
	@Bindable var drink: Dr_M
	@Environment(\.dismiss) private var dismiss
	@StateObject private var auth = AuthService_VM.shared
	@State private var tekst: String = ""
	@State private var zapisuje: Bool = false

	var body: some View {
		NavigationStack {
			TextEditor(text: $tekst)
				.padding()
				.navigationTitle(drink.drNotatka.isEmpty ? "Dodaj notatkę" : "Edytuj notatkę")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .cancellationAction) {
						Button("Anuluj") { dismiss() }
					}
					ToolbarItem(placement: .confirmationAction) {
						if zapisuje {
							ProgressView()
						} else {
							Button("Zapisz") { zapiszNotatke() }
						}
					}
				}
		}
		.onAppear {
			tekst = drink.drNotatka
		}
	}

	private func zapiszNotatke() {
		drink.drNotatka = tekst
		guard auth.isLoggedIn else { dismiss(); return }
		zapisuje = true
		Task {
			if tekst.isEmpty {
				await deleteNoteFromSupabase(drinkId: drink.drinkID)
			} else {
				await saveNoteToSupabase(drinkId: drink.drinkID, note: tekst)
			}
			await MainActor.run {
				zapisuje = false
				dismiss()
			}
		}
	}
}

// MARK: - INFO O PREMIUM

struct PremiumInfo_V: View {
	@Environment(\.dismiss) private var dismiss
	@StateObject private var auth = AuthService_VM.shared

	var body: some View {
		NavigationStack {
			VStack(spacing: 24) {
				Image(systemName: "crown.fill")
					.font(.system(size: 60))
					.foregroundStyle(Color.yellow)

				Text("Funkcja Premium")
					.font(.title2).bold()

				Text("Notatki do drinków są dostępne w planie Premium. Twoje notatki są synchronizowane między urządzeniami i przypisane do Twojego konta.")
					.multilineTextAlignment(.center)
					.foregroundStyle(.secondary)
					.padding(.horizontal)

				if !auth.isLoggedIn {
					Text("Aby skorzystać z Premium, musisz być zalogowany.")
						.font(.footnote)
						.foregroundStyle(.secondary)
						.multilineTextAlignment(.center)
						.padding(.horizontal)
				} else {
					HStack(alignment: .top, spacing: 10) {
						Image(systemName: "ticket")
							.foregroundStyle(Color.accent)
						Text("Premium odblokujesz kodem aktywacyjnym otrzymanym od twórcy aplikacji. Wpisz go w Preferencje → Kod aktywacyjny.")
							.font(.footnote)
							.foregroundStyle(.secondary)
					}
					.padding()
					.background(.regularMaterial)
					.cornerRadius(8)
					.padding(.horizontal)
				}

				Spacer()
			}
			.padding(.top, 40)
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Zamknij") { dismiss() }
				}
			}
		}
	}
}

#Preview {
	NavigationStack {
		DrinkNotatka_V(drink: drMock())
	}
}
