// Arkusz ogólnej opinii o aplikacji (wysyłka do app_feedback).
import SwiftUI

struct AppFeedback_V: View {
	@Environment(\.dismiss) private var dismiss
	@State private var tekst: String = ""
	@State private var wysyla: Bool = false
	@State private var wyslano: Bool = false
	@State private var bladWysylki: Bool = false

	var body: some View {
		NavigationStack {
			VStack(alignment: .leading, spacing: 16) {
				Text("Twoja opinia trafi bezpośrednio do dewelopera. Możesz zgłosić błąd, sugestię lub pomysł na nową funkcję Drinkoteki.")
					.font(.footnote)
					.foregroundStyle(.secondary)

				TextEditor(text: $tekst)
					.frame(minHeight: 120)
					.padding(8)
					.background(.regularMaterial)
					.cornerRadius(8)

				if wyslano {
					Label("Opinia wysłana. Dziękujemy!", systemImage: "checkmark.circle.fill")
						.foregroundStyle(.green)
				}
				if bladWysylki {
					Label("Błąd wysyłki. Spróbuj ponownie.", systemImage: "xmark.circle.fill")
						.foregroundStyle(.red)
				}

				Spacer()
			}
			.padding()
			.navigationTitle("Prześlij opinię")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Anuluj") { dismiss() }
				}
				ToolbarItem(placement: .confirmationAction) {
					if wysyla {
						ProgressView()
					} else {
						Button("Wyślij") { wyslijOpinie() }
							.disabled(tekst.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
					}
				}
			}
		}
	}

	private func wyslijOpinie() {
		wysyla = true
		wyslano = false
		bladWysylki = false
		Task {
			do {
				try await sendAppFeedback(feedback: tekst)
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
	AppFeedback_V()
}
