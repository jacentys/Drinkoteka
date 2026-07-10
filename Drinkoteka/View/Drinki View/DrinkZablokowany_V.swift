import SwiftUI

struct DrinkZablokowany_V: View {
    let drink: Dr_M
    @State private var pokazPremium = false

    var body: some View {
        Button {
            pokazPremium = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(drink.drNazwa)
                        .font(.headline)
                        .foregroundStyle(.primary.opacity(0.4))
                    Text(LocalizedStringKey(drink.drZrodlo))
                        .font(.caption)
                        .foregroundStyle(.secondary.opacity(0.4))
                }
                Spacer()
                Image(systemName: "lock.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary.opacity(0.5))
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $pokazPremium) {
            PremiumInfo_V(opis: "Ten drink jest dostępny w planie Premium. Odblokuj Premium kodem aktywacyjnym, aby zobaczyć przepis.")
        }
    }
}
