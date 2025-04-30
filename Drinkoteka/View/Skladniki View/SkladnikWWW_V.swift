import SwiftUI

struct SkladnikWWW_V: View {
	@Bindable var skladnik: Skl_M

	var body: some View {
		if skladnik.sklWWW.trimmingCharacters(in: .newlines) != "" {
			ZStack {
				VStack(alignment: .leading) {
					
						// MARK: NAGŁOWEK
					HStack(alignment: .firstTextBaseline) {
						Text("Strona WWW:".uppercased())
							.TitleStyle()
						Spacer()
					}
					
						// MARK: LINK
					if let url = URL(string: skladnik.sklWWW) {
						Link(skladnik.sklWWW, destination: url)
							.frame(maxWidth: .infinity)
							.font(.footnote)
							.fontWeight(.light)
							.multilineTextAlignment(.leading)
							.foregroundStyle(.accent)
					} else {
						Text("Problem z linkiem: \(skladnik.sklWWW)")
					}
				}
			}
			.padding(20)
			.background(
				RoundedRectangle(cornerRadius: 12)
					.foregroundStyle(.regularMaterial))
		}
	}
}

#Preview {
	NavigationStack {
		SkladnikWWW_V(skladnik: sklMock())
	}
}
