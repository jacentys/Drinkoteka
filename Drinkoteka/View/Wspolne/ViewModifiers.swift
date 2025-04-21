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
