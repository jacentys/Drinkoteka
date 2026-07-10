// Edycja podstawowych pól istniejącego drinka (admin — wszystkie; premium — tylko własne).
// Moc i kaloryczność są liczone automatycznie ze składników — nieedytowalne tutaj.
import SwiftUI

struct DrinkPolaEdycja_V: View {
    @Bindable var drink: Dr_M
    @Environment(\.dismiss) private var dismiss
    @StateObject private var auth = AuthService_VM.shared

    @State private var nazwa: String = ""
    @State private var kategoria: drKatEnum = .koktail
    @State private var slodycz: drSlodyczEnum = .brakDanych
    @State private var szklo: szkloEnum = .koktailowy
    @State private var uwagi: String = ""
    @State private var www: String = ""
    @State private var zapisuje: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Podstawowe")) {
                    TextField("Nazwa drinka", text: $nazwa)

                    Picker("Kategoria", selection: $kategoria) {
                        ForEach(drKatEnum.allCases, id: \.self) {
                            Text($0.opis).tag($0)
                        }
                    }
                    Picker("Słodycz", selection: $slodycz) {
                        ForEach(drSlodyczEnum.allCases, id: \.self) {
                            Text($0.opis).tag($0)
                        }
                    }
                    Picker("Szkło", selection: $szklo) {
                        ForEach(szkloEnum.allCases, id: \.self) {
                            Text($0.opis).tag($0)
                        }
                    }
                }

                Section(
                    header: Text("Uwagi do przepisu"),
                    footer: Text("Moc i kaloryczność liczone są automatycznie na podstawie listy składników.")
                ) {
                    TextField("Uwagi", text: $uwagi, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Link (WWW)", text: $www)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                }
            }
            .navigationTitle("Edytuj drink")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if zapisuje {
                        ProgressView()
                    } else {
                        Button("Zapisz") { zapisz() }
                            .disabled(nazwa.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
        }
        .onAppear {
            nazwa = drink.drNazwa
            kategoria = drink.drKat
            slodycz = drink.drSlodycz
            szklo = drink.drSzklo
            uwagi = drink.drUwagi
            www = drink.drWWW
        }
    }

    private func zapisz() {
        drink.drNazwa = nazwa.trimmingCharacters(in: .whitespaces)
        drink.drKat = kategoria
        drink.drSlodycz = slodycz
        drink.drSzklo = szklo
        drink.drUwagi = uwagi.trimmingCharacters(in: .whitespacesAndNewlines)
        drink.drWWW = www.trimmingCharacters(in: .whitespaces)
        // Szkło mogło się zmienić — moc liczona jest też z pojemności szkła
        przeliczMocIKalorie(drink)

        // v1: edycja lokalna. Wypychamy na serwer tylko treść serwerową
        // (drZrodlo != "Własny"); "Własny" zostaje lokalny do fazy synchronizacji.
        guard auth.isAdmin, drink.drZrodlo != "Własny" else { dismiss(); return }
        zapisuje = true
        Task {
            await pushPolaAdmin(drink: drink)
            await MainActor.run {
                zapisuje = false
                dismiss()
            }
        }
    }
}

#Preview {
    DrinkPolaEdycja_V(drink: drMock())
}
