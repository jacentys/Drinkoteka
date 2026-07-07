import SwiftUI

struct DrinkZablokowany_V: View {
    let drink: Dr_M

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(drink.drNazwa)
                    .font(.headline)
                    .foregroundStyle(.primary.opacity(0.4))
                Text(drink.drZrodlo)
                    .font(.caption)
                    .foregroundStyle(.secondary.opacity(0.4))
            }
            Spacer()
            Image(systemName: "lock.fill")
                .font(.title2)
                .foregroundStyle(.secondary.opacity(0.5))
        }
        .padding(.vertical, 4)
        .overlay(
            NavigationLink(destination: AuthLogowanie_V()) {
                Color.clear
            }
        )
    }
}
