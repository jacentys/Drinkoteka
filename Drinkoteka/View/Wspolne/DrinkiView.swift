import SwiftUI

struct Dr_V: View {

	@AppStorage("opcjonalneWymagane") var opcjonalneWymagane: Bool = false
	@AppStorage("zamiennikiDozwolone") var zamiennikiDozwolone: Bool = false
	@AppStorage("tylkoUlubione") var tylkoUlubione: Bool = false
	@AppStorage("tylkoDostepne") var tylkoDostepne: Bool = false

	@State private var pokazFiltr = false

	var body: some View {
#if os(iOS)
		NavigationView {
			VStack {
					// Górna część ekranu (zawiera toolbar z przyciskami)
				VStack {
					Text("Drinki")
						.font(.largeTitle)
						.padding()

						// Przyciski nawigacji (lewa strona) - dostępne, ulubione, opcjonalne, zamienniki
						.toolbar {
							ToolbarItem(placement: .navigationBarLeading) {
								HStack(spacing: 5) {
									Button {
										tylkoDostepne.toggle()
									} label: {
										Image(systemName: tylkoDostepne ? "checkmark.circle.fill" : "checkmark.circle")
											.font(.title2)
											.foregroundStyle(tylkoDostepne ? Color.accent : Color.secondary)
									}

									Button {
										tylkoUlubione.toggle()
									} label: {
										Image(systemName: tylkoUlubione ? "star.circle.fill" : "star.circle")
											.font(.title2)
											.foregroundStyle(tylkoUlubione ? Color.accent : Color.secondary)
									}

									Button {
										opcjonalneWymagane.toggle()
									} label: {
										Image(systemName: opcjonalneWymagane ? "list.bullet.circle.fill" : "list.bullet.circle")
											.font(.title2)
											.foregroundStyle(opcjonalneWymagane ? Color.accent : Color.secondary)
									}

									Button {
										zamiennikiDozwolone.toggle()
									} label: {
										Image(systemName: zamiennikiDozwolone ? "repeat.circle.fill" : "repeat.circle")
											.font(.title2)
											.foregroundStyle(zamiennikiDozwolone ? Color.accent : Color.secondary)
									}
								}
							}

								// Przycisk filtru po prawej stronie
							ToolbarItem(placement: .navigationBarTrailing) {
								Button {
									pokazFiltr.toggle()
								} label: {
									Text("Filtry")
								}
								.buttonStyle(.borderedProminent)
								.sheet(isPresented: $pokazFiltr) {
									DrinkFiltry_V()
										.presentationDetents([.large])
								}
							}
						}
				}

				Spacer()

					// Dolny pasek (TabBar)
				CustomTab_V()
			}
		}
#elseif os(macOS)
		VStack {
			Text("Drinki")
				.font(.largeTitle)
				.padding()

				// Przyciski nawigacji (lewa strona) - dostępne, ulubione, opcjonalne, zamienniki
				.toolbar {
					ToolbarItem {
						HStack(spacing: 5) {
							Button {
								tylkoDostepne.toggle()
							} label: {
								Image(systemName: tylkoDostepne ? "checkmark.circle.fill" : "checkmark.circle")
									.font(.title2)
									.foregroundStyle(tylkoDostepne ? Color.accent : Color.secondary)
							}

							Button {
								tylkoUlubione.toggle()
							} label: {
								Image(systemName: tylkoUlubione ? "star.circle.fill" : "star.circle")
									.font(.title2)
									.foregroundStyle(tylkoUlubione ? Color.accent : Color.secondary)
							}

							Button {
								opcjonalneWymagane.toggle()
							} label: {
								Image(systemName: opcjonalneWymagane ? "list.bullet.circle.fill" : "list.bullet.circle")
									.font(.title2)
									.foregroundStyle(opcjonalneWymagane ? Color.accent : Color.secondary)
							}

							Button {
								zamiennikiDozwolone.toggle()
							} label: {
								Image(systemName: zamiennikiDozwolone ? "repeat.circle.fill" : "repeat.circle")
									.font(.title2)
									.foregroundStyle(zamiennikiDozwolone ? Color.accent : Color.secondary)
							}
						}
					}

						// Przycisk filtru po prawej stronie
					ToolbarItem(placement: .confirmationAction) {
						Button {
							pokazFiltr.toggle()
						} label: {
							Text("Filtry")
						}
						.buttonStyle(.borderedProminent)
						.sheet(isPresented: $pokazFiltr) {
							DrinkFiltry_V()
								.presentationDetents([.large])
						}
					}
				}
		}

		Spacer()

			// Dolny pasek (TabBar)
		CustomTabView()
#endif
	}
}

#Preview {
	Dr_V()
}
