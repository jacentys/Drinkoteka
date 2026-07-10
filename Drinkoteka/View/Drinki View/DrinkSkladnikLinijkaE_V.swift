// Edytowalny wiersz składnika drinka: ilość/miara/info/opcjonalny + usuwanie.
import SwiftUI

struct DrinkSkladnikLinijkaE_V: View {
	@Bindable var drSkladnik: DrSkladnik_M
	let onUsun: () -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			HStack {
				Text(drSkladnik.skladnik.sklNazwa)
					.fontWeight(.medium)
				Spacer()
				Toggle("Opcjonalny", isOn: $drSkladnik.sklOpcja)
					.labelsHidden()
					.tint(.secondary)
				Button(role: .destructive) {
					onUsun()
				} label: {
					Image(systemName: "trash")
						.foregroundStyle(.red)
				}
				.buttonStyle(.plain)
			}
			HStack(spacing: 8) {
				TextField("Ilość", value: $drSkladnik.sklIlosc, format: .number)
					.keyboardType(.decimalPad)
					.frame(width: 60)
					.textFieldStyle(.roundedBorder)

				Picker("", selection: $drSkladnik.sklMiara) {
					ForEach(miaraEnum.allCases, id: \.self) {
						Text($0.opis).tag($0)
					}
				}
				.pickerStyle(.menu)

				TextField("Info", text: $drSkladnik.sklInfo)
					.textFieldStyle(.roundedBorder)
					.font(.caption)
			}
		}
		.padding(.vertical, 2)
	}
}

#Preview {
	DrinkSkladnikLinijkaE_V(drSkladnik: drMock().drSklad[0]) {}
}
