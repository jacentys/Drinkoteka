// Ekran wyboru języka przy pierwszym uruchomieniu — pokazywany raz, przed
// pobraniem treści z Supabase, żeby dane od razu ładowały się w wybranym języku.
// Wybór da się zmienić później w Preferencjach.
import SwiftUI

struct JezykWyboru_V: View {
	var onWybierz: (String) -> Void

	@State private var puls = false

	var body: some View {
		ZStack {
			LinearGradient(
				colors: [Color(red: 1.0, green: 0.42, blue: 0.06),
						 Color(red: 0.85, green: 0.33, blue: 0.0)],
				startPoint: .top, endPoint: .bottom)
			.ignoresSafeArea()

			VStack(spacing: 28) {
				Image(systemName: "wineglass.fill")
					.font(.system(size: 72))
					.foregroundStyle(.white)
					.scaleEffect(puls ? 1.06 : 0.94)
					.animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: puls)

				VStack(spacing: 6) {
					Text("Wybierz język / Choose language")
						.font(.title2).fontWeight(.semibold)
						.foregroundStyle(.white)
						.multilineTextAlignment(.center)
					Text("Możesz to później zmienić w Preferencjach.\nYou can change this later in Settings.")
						.font(.footnote)
						.foregroundStyle(.white.opacity(0.85))
						.multilineTextAlignment(.center)
				}
				.padding(.horizontal, 32)

				VStack(spacing: 14) {
					Button {
						onWybierz("pl")
					} label: {
						Text("Polski")
							.font(.headline)
							.foregroundStyle(Color(red: 1, green: 0.4, blue: 0))
							.frame(maxWidth: .infinity)
							.padding(.vertical, 14)
							.background(.white)
							.clipShape(Capsule())
					}

					Button {
						onWybierz("en")
					} label: {
						Text("English")
							.font(.headline)
							.foregroundStyle(.white)
							.frame(maxWidth: .infinity)
							.padding(.vertical, 14)
							.overlay(Capsule().stroke(.white, lineWidth: 1.5))
					}
				}
				.padding(.horizontal, 40)
			}
		}
		.onAppear { puls = true }
	}
}

#Preview {
	JezykWyboru_V(onWybierz: { _ in })
}
