import SwiftUI

struct DrinkListaRow_V: View {
    let drink: Dr_M

    var body: some View {
        HStack {
            // MARK: - IKONKA
            ZStack {
                Circle()
                    .fill(.regularMaterial)
                    .stroke(drink.getKolor(), lineWidth: drink.drBrakuje == 0 ? 2 : 1)

                DrinkotekaImage_V(nazwa: drink.drFoto, fallback: drink.drSzklo.foto)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35, height: 35)
                    .foregroundStyle(Color.primary)

                Image(systemName: "checkmark")
                    .font(.system(size: 12))
                    .fontWeight(.black)
                    .frame(width: 60, height: 50, alignment: .bottomTrailing)
                    .foregroundStyle(Color.primary.opacity(drink.drBrakuje == 0 ? 1 : 0))
            }
            .frame(width: 50, height: 50)

            Divider().frame(height: 50)

            // MARK: - OPIS
            VStack(spacing: 0) {
                VStack(alignment: .leading) {
                    Spacer()
                    Text(drink.drNazwa)
                        .font(.headline)
                    Divider().padding(0)
                    (Text(LocalizedStringKey(drink.drMoc.opisShort)) + Text(" (\(drink.drProc)%) | \(drink.drKal) kCal"))
                        .font(.caption)
                    Spacer()
                }
                .foregroundStyle(Color.primary)
            }
            .frame(maxWidth: .infinity)

            Divider().frame(height: 50)

            // MARK: - SKALA
            DrinkSkala_V(drink: drink, wielkosc: 20, etykieta: false)
                .shadow(color: .white, radius: 20)
                .padding(.leading, 8)

            // MARK: - GWIAZDKA
            Image(systemName: drink.drUlubiony ? "star.fill" : "star")
                .font(.system(size: 23))
                .foregroundStyle(drink.drUlubiony ? Color.accent : Color.gray)
                .onTapGesture { drink.ulubionyToggle() }
        }
    }
}
