// Szczegóły konta: email, dostęp do kategorii, zmiana hasła, wylogowanie, usunięcie konta.
import SwiftUI

struct AuthProfil_V: View {
    @StateObject private var auth = AuthService_VM.shared
    @StateObject private var store = StoreKit_VM.shared
    @Environment(\.dismiss) private var dismiss

    @State private var noweHaslo: String = ""
    @State private var potwierdzHaslo: String = ""
    @State private var pokazZmianeHasla: Bool = false
    @State private var pokazPotwierdzenieDelekcji: Bool = false
    @State private var komunikat: String? = nil
    @State private var infoKonto: Bool = false
    @State private var infoPremium: Bool = false
    @State private var infoUsunKonto: Bool = false
    @State private var infoUrzadzenia: Bool = false
    @State private var urzadzenia: [UrzadzenieDTO] = []

        // Nagłówek sekcji z ikoną informacji + popoverem (jak w Preferencjach/filtrach drinków).
    private func naglowek(_ tytul: LocalizedStringKey, systemImage: String, kolor: Color,
                           opis: LocalizedStringKey, pokaz: Binding<Bool>) -> some View {
        HStack {
            Label(tytul, systemImage: systemImage)
                .font(.title2)
                .fontWeight(.light)
                .foregroundStyle(kolor)
            Spacer()
            Button { pokaz.wrappedValue = true } label: {
                Image(systemName: "info.circle").foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .popover(isPresented: pokaz) {
                Text(opis)
                    .font(.footnote)
                    .textCase(nil)
                    .frame(width: 260, alignment: .leading)
                    .padding()
                    .presentationCompactAdaptation(.popover)
            }
        }
    }

    var body: some View {
        List {
            Section(header: naglowek("Konto", systemImage: "person.crop.circle", kolor: Color.white,
                                      opis: "Adres e-mail, na który zarejestrowane jest Twoje konto. Służy do logowania i synchronizacji danych.",
                                      pokaz: $infoKonto)) {
                HStack {
                    Image(systemName: "envelope")
                        .foregroundStyle(.secondary)
                    Text(auth.userEmail)
                    if auth.isPremium {
                        Spacer()
                        VStack(spacing: 2) {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(.yellow)
                            Text("PREMIUM")
                                .font(.system(size: 8))
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            if !auth.isPremium {
                Section(
                    header: naglowek("Premium", systemImage: "crown", kolor: Color.white,
                                      opis: "Premium odblokowuje wszystkie kategorie drinków, notatki i tworzenie własnych przepisów. Promocyjny kod Apple działa tak samo jak zakup.",
                                      pokaz: $infoPremium)
                ) {
                if store.isLoadingProducts {
                    ProgressView()
                } else {
                    ForEach(store.products, id: \.id) { product in
                        Button {
                            Task { await store.purchase(product) }
                        } label: {
                            HStack {
                                Text(product.displayName)
                                Spacer()
                                Text(product.displayPrice)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                        .disabled(store.isPurchasing)
                    }

                    Button {
                        Task { await store.restorePurchases() }
                    } label: {
                        Text("Przywróć zakupy")
                            .font(.footnote)
                    }
                }
                }
            }

            Section(
                header: naglowek("Urządzenia", systemImage: "iphone.gen3", kolor: Color.white,
                                  opis: "Limit \(LIMIT_URZADZEN) urządzeń na koncie — chroni przed współdzieleniem loginu i hasła. Jeśli dodajesz nowe urządzenie ponad limit, usuń tu jedno ze starych.",
                                  pokaz: $infoUrzadzenia)
            ) {
                if auth.isPremiumRaw && !auth.deviceAuthorized {
                    Text("To urządzenie przekroczyło limit \(LIMIT_URZADZEN) i nie ma dostępu do Premium. Usuń jedno z poniższych, żeby je odblokować.")
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
                ForEach(urzadzenia) { urz in
                    HStack {
                        Image(systemName: "iphone")
                            .foregroundStyle(.secondary)
                        Text(urz.deviceName ?? "Urządzenie")
                        Spacer()
                        if urz.deviceId == aktualneUrzadzenieId() {
                            Text("to urządzenie")
                                .font(.caption)
                        }
                    }
                }
                .onDelete { indexSet in
                    Task { await usunUrzadzenia(at: indexSet) }
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
                        Group {
                            if auth.isLoading {
                                ProgressView()
                            } else {
                                Text("Zapisz nowe hasło")
                            }
                        }
                    }

                    Button(role: .cancel) {
                        pokazZmianeHasla = false
                        noweHaslo = ""
                        potwierdzHaslo = ""
                        komunikat = nil
                    } label: {
                        Text("Anuluj")
                    }
                } else {
                    Button {
                        pokazZmianeHasla = true
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "lock.rotation")
                            Text("Zmień hasło")
                            Spacer()
                        }
                    }
                }
            }

            Section {
                Button {
                    Task {
                        await auth.signOut()
                        dismiss()
                    }
                } label: {
                    Group {
                        if auth.isLoading {
                            ProgressView()
                        } else {
                            HStack {
                                Spacer()
                                Label("Wyloguj się", systemImage: "rectangle.portrait.and.arrow.right")
                                Spacer()
                            }
                        }
                    }
                }
            }

            Section(
                header: naglowek("Usuń konto", systemImage: "trash", kolor: Color.white,
                                  opis: "Usunięcie konta jest nieodwracalne. Wszystkie Twoje dane zostaną trwale usunięte.",
                                  pokaz: $infoUsunKonto)
            ) {
                Button(role: .destructive) {
                    pokazPotwierdzenieDelekcji = true
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: "trash")
                            .font(.footnote)
                        Text("Usuń konto")
                        Spacer()
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 30)
        }
        .background(Back_V().ignoresSafeArea())
        .task {
            urzadzenia = await listDevicesFromSupabase()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Ten sam styl tytułu, co "Drinkotheque" na ekranie głównym —
            // spójny wygląd nagłówków ekranów w całej aplikacji.
            ToolbarItem(placement: .principal) {
                Text("Szczegóły konta")
                    .font(.largeTitle)
                    .fontWeight(.light)
                    .foregroundStyle(Color.primary)
                    .shadow(color: .black.opacity(0.6), radius: 6)
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Material.thickMaterial, for: .navigationBar)
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

    // MARK: - USUŃ URZĄDZENIE
    private func usunUrzadzenia(at indexSet: IndexSet) async {
        for index in indexSet {
            await removeDeviceFromSupabase(deviceId: urzadzenia[index].deviceId)
        }
        urzadzenia = await listDevicesFromSupabase()
        await auth.refreshPremiumStatus()
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
