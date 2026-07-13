// Krótki, samoznikający komunikat (np. "Pokazuję tylko ulubione") pokazywany
// po zmianie filtra przełącznikiem w toolbarze. Użycie: .toast(message: $toastMessage).
import SwiftUI

private struct Toast_V: ViewModifier {
	@Binding var message: String?

	func body(content: Content) -> some View {
		content
			.overlay(alignment: .top) {
				if let message {
					Text(message)
						.font(.footnote)
						.fontWeight(.medium)
						.padding(.horizontal, 16)
						.padding(.vertical, 8)
						.background(.regularMaterial, in: Capsule())
						.shadow(color: .black.opacity(0.15), radius: 4, y: 2)
						.padding(.top, 8)
						.transition(.move(edge: .top).combined(with: .opacity))
						.onAppear {
							Task {
								try? await Task.sleep(nanoseconds: 1_200_000_000)
								withAnimation {
									self.message = nil
								}
							}
						}
				}
			}
			.animation(.easeInOut(duration: 0.25), value: message)
	}
}

extension View {
	func toast(message: Binding<String?>) -> some View {
		self.modifier(Toast_V(message: message))
	}
}
