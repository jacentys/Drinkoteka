// Ekran szczegółów drinka + wysyłka uwagi o drinku do dewelopera.
import SwiftData
import SwiftUI

struct Drink_V: View {
	@Bindable var drink: Dr_M
	@Environment(\.modelContext) private var modelContext
	@StateObject private var auth = AuthService_VM.shared
	@State private var pokazUwagi: Bool = false

	var body: some View {
		ZStack {
			DrinkBack_V(drink: drink)

			ScrollView {
				VStack(spacing: 12) {
					DrinkTitle_V(drink: drink)
					DrinkFoto_V(drink: drink)
					DrinkDane_V(drink: drink)
					DrinkNotatka_V(drink: drink)
					DrinkSkladniki_V(drink: drink)
					DrinkPrzepis_V(drink: drink)
					DrinkWWW_V(drink: drink)
				}
				.padding(.vertical, 30)
			}
			.padding(.horizontal, 20)
		}
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Button {
					pokazUwagi = true
				} label: {
					Image(systemName: "exclamationmark.bubble")
				}
				.sheet(isPresented: $pokazUwagi) {
					DrinkUwaga_V(drink: drink)
				}
			}
		}
		.task {
			await loadNotesFromSupabase(modelContext: modelContext)
		}
	}
}

// MARK: - FORMULARZ UWAGI

struct DrinkUwaga_V: View {
	let drink: Dr_M
	@Environment(\.dismiss) private var dismiss
	@State private var tekst: String = ""
	@State private var wysyla: Bool = false
	@State private var wyslano: Bool = false
	@State private var bladWysylki: Bool = false

	var body: some View {
		NavigationStack {
			VStack(alignment: .leading, spacing: 16) {
				Text("Twoja uwaga trafi bezpośrednio do dewelopera. Możesz zgłosić błąd, sugestię lub brakujące dane dotyczące tego drinka.")
					.font(.footnote)
					.foregroundStyle(.secondary)

				TextEditor(text: $tekst)
					.frame(minHeight: 120)
					.padding(8)
					.background(.regularMaterial)
					.cornerRadius(8)

				if wyslano {
					Label("Uwaga wysłana. Dziękujemy!", systemImage: "checkmark.circle.fill")
						.foregroundStyle(.green)
				}
				if bladWysylki {
					Label("Błąd wysyłki. Spróbuj ponownie.", systemImage: "xmark.circle.fill")
						.foregroundStyle(.red)
				}

				Spacer()
			}
			.padding()
			.navigationTitle(drink.drNazwa)
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Anuluj") { dismiss() }
				}
				ToolbarItem(placement: .confirmationAction) {
					if wysyla {
						ProgressView()
					} else {
						Button("Wyślij") { wyslijUwage() }
							.disabled(tekst.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
					}
				}
			}
		}
	}

	private func wyslijUwage() {
		wysyla = true
		wyslano = false
		bladWysylki = false
		Task {
			do {
				try await sendDrinkFeedback(drinkId: drink.drinkID, feedback: tekst)
				await MainActor.run {
					wysyla = false
					wyslano = true
					tekst = ""
				}
				try? await Task.sleep(for: .seconds(1.5))
				await MainActor.run { dismiss() }
			} catch {
				await MainActor.run {
					wysyla = false
					bladWysylki = true
				}
			}
		}
	}
}

#Preview {
	NavigationStack {
		Drink_V(drink: drMock())
	}
}
