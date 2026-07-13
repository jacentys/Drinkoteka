// Szczegóły konta: email, dostęp do kategorii, zmiana hasła, wylogowanie, usunięcie konta.
import SwiftUI

struct AuthProfil_V: View {
    @StateObject private var auth = AuthService_VM.shared
    @StateObject private var store = StoreKit_VM.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var noweHaslo: String = ""
    @State private var potwierdzHaslo: String = ""
    @State private var pokazZmianeHasla: Bool = false
    @State private var pokazPotwierdzenieDelekcji: Bool = false
    @State private var komunikat: String? = nil

    @State private var kodAktywacyjny: String = ""
    @State private var komunikatKodu: String? = nil
    @State private var aktywujeKod: Bool = false

    var body: some View {
        List {
            Section(header: Text("Konto")) {
                HStack {
                    Image(systemName: "envelope")
                        .foregroundStyle(.secondary)
                    Text(auth.userEmail)
                }
            }

            Section(
                header: Text("Premium"),
                footer: Text("Premium odblokowuje wszystkie kategorie drinków, notatki i tworzenie własnych przepisów. Otrzymany za darmo kod aktywacyjny lub promocyjny kod Apple działa tak samo jak zakup.")
            ) {
                if auth.isPremium {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(.yellow)
                        Text("Masz aktywne Premium")
                    }
                } else if store.isLoadingProducts {
                    ProgressView()
                } else {
                    ForEach(store.products, id: \.id) { product in
                        Button {
                            Task { await store.purchase(product) }
                        } label: {
                            HStack {
                                Text(product.displayName)
                                    .foregroundStyle(Color.accent)
                                Spacer()
                                Text(product.displayPrice)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .disabled(store.isPurchasing)
                    }
                }

                Button {
                    Task { await store.restorePurchases() }
                } label: {
                    Text("Przywróć zakupy")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            // Pokazujemy tylko kategorie, do których użytkownik MA dostęp.
            // Jeśli nie ma żadnej — sekcja się nie pojawia (nie ujawniamy istnienia
            // kategorii, do których dostępu nie ma).
            if !auth.dostepneKategorie.isEmpty {
                Section(
                    header: Text("Twoje kategorie"),
                    footer: Text("Masz dostęp do dodatkowych kategorii przyznany przez administratora.")
                ) {
                    ForEach(auth.dostepneKategorie, id: \.self) { source in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text(LocalizedStringKey(source))
                        }
                    }
                }
            }

            Section(
                header: Text("Kod aktywacyjny"),
                footer: Text("Wpisz kod otrzymany od twórcy aplikacji, aby odblokować Premium lub dodatkowe kategorie.")
            ) {
                TextField("Wpisz kod", text: $kodAktywacyjny)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                if let k = komunikatKodu {
                    Text(k)
                        .font(.caption)
                        .foregroundStyle(k.hasPrefix("✓") ? .green : .red)
                }
                Button {
                    Task { await aktywujKod() }
                } label: {
                    if aktywujeKod {
                        ProgressView()
                    } else {
                        Text("Aktywuj").foregroundStyle(Color.accent)
                    }
                }
                .disabled(kodAktywacyjny.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || aktywujeKod)
            }

            Section(header: Text("Zmiana hasła")) {
                if pokazZmianeHasla {
                    SecureField("Nowe hasło", text: $noweHaslo)
                    SecureField("Potwierdź hasło", text: $potwierdzHaslo)
                    if let k = komunikat {
                        Text(k)
                            .font(.caption)
                            .foregroundStyle(k.hasPrefix("✓") ? .green : .red)
                    }
                    Button {
                        Task { await zmienHaslo() }
                    } label: {
                        if auth.isLoading {
                            ProgressView()
                        } else {
                            Text("Zapisz nowe hasło")
                        }
                    }
                    Button("Anuluj", role: .cancel) {
                        pokazZmianeHasla = false
                        noweHaslo = ""
                        potwierdzHaslo = ""
                        komunikat = nil
                    }
                } else {
                    Button("Zmień hasło") {
                        pokazZmianeHasla = true
                    }
                }
            }

            Section {
                Button(role: .destructive) {
                    Task {
                        await auth.signOut()
                        dismiss()
                    }
                } label: {
                    if auth.isLoading {
                        ProgressView()
                    } else {
                        Label("Wyloguj się", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }

            Section(footer: Text("Usunięcie konta jest nieodwracalne. Wszystkie Twoje dane zostaną trwale usunięte.")) {
                Button(role: .destructive) {
                    pokazPotwierdzenieDelekcji = true
                } label: {
                    Label("Usuń konto", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Szczegóły konta")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Czy na pewno chcesz usunąć konto?",
            isPresented: $pokazPotwierdzenieDelekcji,
            titleVisibility: .visible
        ) {
            Button("Usuń konto", role: .destructive) {
                Task {
                    await auth.deleteAccount()
                    dismiss()
                }
            }
            Button("Anuluj", role: .cancel) {}
        } message: {
            Text("Ta operacja jest nieodwracalna.")
        }
    }

    // MARK: - AKTYWACJA KODU
    private func aktywujKod() async {
        aktywujeKod = true
        komunikatKodu = nil
        let wynik = await auth.redeemCode(kodAktywacyjny)
        switch wynik {
            case "ok":
                komunikatKodu = "✓ Kod aktywowany."
                kodAktywacyjny = ""
                // Dociągnij drinki odblokowanej kategorii (idempotentne)
                await loadFromSupabase(modelContext: modelContext)
                await loadNotesFromSupabase(modelContext: modelContext)
            case "invalid":       komunikatKodu = "Nieprawidłowy kod."
            case "expired":       komunikatKodu = "Kod wygasł."
            case "wrong_account": komunikatKodu = "Kod przypisany do innego konta."
            case "already_used":  komunikatKodu = "Ten kod został już przez Ciebie użyty."
            case "exhausted":     komunikatKodu = "Kod osiągnął limit użyć."
            case "not_logged_in": komunikatKodu = "Musisz być zalogowany."
            default:              komunikatKodu = "Błąd aktywacji. Spróbuj ponownie."
        }
        aktywujeKod = false
    }

    func zmienHaslo() async {
        guard noweHaslo == potwierdzHaslo else {
            komunikat = "Hasła nie są zgodne."
            return
        }
        guard noweHaslo.count >= 6 else {
            komunikat = "Hasło musi mieć co najmniej 6 znaków."
            return
        }
        await auth.changePassword(noweHaslo: noweHaslo)
        if auth.errorMessage == nil {
            komunikat = "✓ Hasło zostało zmienione."
            noweHaslo = ""
            potwierdzHaslo = ""
            pokazZmianeHasla = false
        } else {
            komunikat = auth.errorMessage
        }
    }
}

#Preview {
    NavigationStack {
        AuthProfil_V()
    }
}
