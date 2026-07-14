import SwiftUI

struct ButtonModifier: ViewModifier {
	func body(content: Content) -> some View {
		content
			.font(.headline)
			.padding(.horizontal, 16)
			.padding(.vertical, 4)
			.foregroundStyle(Color.white)
			.background(Color.accent)
			.cornerRadius(8)
	}
}
struct SectionTitleModifier: ViewModifier {
	func body(content: Content) -> some View {
		content
			.font(.headline)
			.foregroundColor(Color.accent)
			.fontWeight(.black)
			.padding(.bottom, 10)
	}
}
struct RectDefaultCorner: ViewModifier {
	func body(content: Content) -> some View {
		content
			.cornerRadius(10)
	}
}

// Spójny rozmiar/kształt przycisków w List/Form (Preferencje, Szczegóły konta) —
// tło i (opcjonalna) obwódka rysowane na tej samej ramce co treść, więc nie da
// się ich rozjechać tak jak z systemowym listRowBackground (patrz historia tej
// poprawki: różne zaokrąglenie tła wiersza vs ręcznie rysowanej ramki).
// Kolor treści (tekst/ikona) zostaje ustawiany osobno przy każdym przycisku —
// ten modifier odpowiada tylko za tło/rozmiar, nie za kolor napisu.
struct KapsulaTloModifier: ViewModifier {
	var tlo: Color = .white
	var obwodka: Bool = false

	func body(content: Content) -> some View {
		content
			.frame(maxWidth: .infinity)
			.padding(.vertical, 12)
			.background(Capsule().fill(tlo))
			.overlay {
				if obwodka {
					Capsule().stroke(Color.white, lineWidth: 1.5)
				}
			}
	}
}

extension View {
	func kapsulaTlo(_ tlo: Color = .white, obwodka: Bool = false) -> some View {
		modifier(KapsulaTloModifier(tlo: tlo, obwodka: obwodka))
	}

	// Ujednolicone ustawienia wiersza List/Form dla przycisku w stylu kapsuły —
	// celowo BEZ własnego listRowInsets, żeby szerokość wiersza pozostała
	// identyczna jak przy zwykłych, niestylowanych wierszach (np. e-mail w
	// sekcji Konto) — inaczej kapsuła wychodzi węższa/szersza niż reszta listy.
	// Przezroczyste tło wiersza, bo kapsuła sama rysuje swoje tło; bez separatora.
	func kapsulaWiersz() -> some View {
		self
			.listRowBackground(Color.clear)
			.listRowSeparator(.hidden)
	}
}

extension Text {
	func EditButton() -> some View {
		modifier(ButtonModifier())
	}
	func TitleStyle() -> some View {
		modifier(SectionTitleModifier())
	}
	func defaultCorner() -> some View {
		modifier(RectDefaultCorner())
	}
}

#Preview {
	Text("Test")
		.TitleStyle()
}
