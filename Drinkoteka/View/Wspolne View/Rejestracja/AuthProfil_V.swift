// Szczegóły konta: email, dostęp do kategorii, zmiana hasła, wylogowanie, usunięcie konta.
import SwiftUI

struct AuthProfil_V: View {
    @StateObject private var auth = AuthService_VM.shared
    @Environment(\.dismiss) private var dismiss

    @State private var noweHaslo: String = ""
    @State private var potwierdzHaslo: String = ""
    @State private var pokazZmianeHasla: Bool = false
    @State private var pokazPotwierdzenieDelekcji: Bool = false
    @State private var komunikat: String? = nil

    var body: some View {
        List {
            Section(header: Text("Konto")) {
                HStack {
                    Image(systemName: "envelope")
                        .foregroundStyle(.secondary)
                    Text(auth.userEmail)
                }
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(.yellow)
                    Text("Konto Premium")
                        .foregroundStyle(.secondary)
                }
            }

            if !auth.zablokowaneZrodla.isEmpty {
                Section(
                    header: Text("Dostęp do kategorii"),
                    footer: Text("Dostęp do kategorii specjalnych przyznaje administrator.")
                ) {
                    ForEach(auth.zablokowaneZrodla, id: \.source) { item in
                        HStack {
                            Image(systemName: item.dostep ? "checkmark.circle.fill" : "lock.fill")
                                .foregroundStyle(item.dostep ? .green : .secondary)
                            Text(LocalizedStringKey(item.source))
                            Spacer()
                            Text(item.dostep ? "Dostęp" : "Brak dostępu")
                                .font(.caption)
                                .foregroundStyle(.secondary)
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
