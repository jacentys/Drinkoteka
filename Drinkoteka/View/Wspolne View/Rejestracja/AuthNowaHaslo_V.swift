// Ekran ustawienia nowego hasła po kliknięciu linku odzyskiwania z maila.
// Prezentowany jako fullScreenCover z korzenia appki, gdy AuthService_VM
// wykryje event .passwordRecovery (patrz observeAuthStateChanges).
import SwiftUI

struct AuthNowaHaslo_V: View {
    @StateObject private var auth = AuthService_VM.shared

    @State private var noweHaslo: String = ""
    @State private var potwierdzHaslo: String = ""
    @State private var localError: String? = nil
    @State private var zapisano: Bool = false

    var body: some View {
        ZStack {
            Back_V(kolor: .accent)
            GeometryReader { geo in
                ScrollView {
                    content
                        .frame(minHeight: geo.size.height)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
    }

    private var content: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "lock.rotation")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(.white)

            Text("Ustaw nowe hasło")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            if !auth.userEmail.isEmpty {
                Text(auth.userEmail)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
            }

            if zapisano {
                potwierdzenie
            } else {
                formularz
            }

            Spacer()
        }
        .padding(.horizontal, 30)
    }

    private var formularz: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                SecureField("nowe hasło...", text: $noweHaslo)
                    .foregroundStyle(.black)
                    .tint(.accent)
                    .padding()
                    .background(.white)
                    .cornerRadius(10)

                SecureField("powtórz nowe hasło...", text: $potwierdzHaslo)
                    .foregroundStyle(.black)
                    .tint(.accent)
                    .padding()
                    .background(.white)
                    .cornerRadius(10)
            }

            if let error = localError ?? auth.errorMessage {
                Text(error)
                    .foregroundStyle(.yellow)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }

            Button {
                Task { await zapisz() }
            } label: {
                Group {
                    if auth.isLoading {
                        ProgressView()
                            .tint(.accent)
                    } else {
                        Text("Zapisz nowe hasło")
                            .font(.headline)
                            .foregroundStyle(.accent)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(.white)
                .cornerRadius(12)
                .shadow(radius: 6)
            }

            Button {
                auth.isPasswordRecoveryFlow = false
            } label: {
                Text("Anuluj")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }

    private var potwierdzenie: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.largeTitle)
                .foregroundStyle(.white)
            Text("Hasło zostało zmienione.")
                .foregroundStyle(.white)
                .font(.footnote)

            Button {
                auth.isPasswordRecoveryFlow = false
            } label: {
                Text("Przejdź do aplikacji")
                    .font(.headline)
                    .foregroundStyle(.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(.white)
                    .cornerRadius(12)
                    .shadow(radius: 6)
            }
        }
    }

    // MARK: - Akcje

    private func zapisz() async {
        localError = nil
        guard noweHaslo.count >= 6 else {
            localError = "Hasło musi mieć co najmniej 6 znaków."
            return
        }
        guard noweHaslo == potwierdzHaslo else {
            localError = "Hasła nie są zgodne."
            return
        }
        await auth.changePassword(noweHaslo: noweHaslo)
        if auth.errorMessage == nil {
            withAnimation { zapisano = true }
        }
    }
}

#Preview {
    AuthNowaHaslo_V()
}
