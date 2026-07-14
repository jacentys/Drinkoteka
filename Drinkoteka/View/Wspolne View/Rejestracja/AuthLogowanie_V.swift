// Ekran logowania/rejestracji przez Supabase Auth.
import SwiftUI

struct AuthLogowanie_V: View {
    @StateObject private var auth = AuthService_VM.shared

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var potwierdzHaslo: String = ""
    @State private var tryb: Tryb = .logowanie
    @State private var localError: String? = nil
    @State private var resetWyslany: Bool = false

    enum Tryb { case logowanie, rejestracja }

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
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.white, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
    }

    private var content: some View {
        VStack(spacing: 24) {
            Spacer()

                Image(systemName: "wineglass.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.white)

                Text(tryb == .logowanie ? "Zaloguj się" : "Zarejestruj się")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                VStack(spacing: 12) {
                    TextField("e-mail...", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .foregroundStyle(.black)   // tło jest białe → tekst ciemny także w dark mode
                        .tint(.accent)
                        .padding()
                        .background(.white)
                        .cornerRadius(10)

                    SecureField("hasło...", text: $password)
                        .foregroundStyle(.black)
                        .tint(.accent)
                        .padding()
                        .background(.white)
                        .cornerRadius(10)

                    if tryb == .rejestracja {
                        SecureField("powtórz hasło...", text: $potwierdzHaslo)
                            .foregroundStyle(.black)
                            .tint(.accent)
                            .padding()
                            .background(.white)
                            .cornerRadius(10)
                    }
                }

                if tryb == .logowanie {
                    Button {
                        Task { await wyslijReset() }
                    } label: {
                        Text("Zapomniałeś hasła?")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.8))
                            .underline()
                    }
                }

                if auth.oczekujeNaPotwierdzenieMaila {
                    VStack(spacing: 12) {
                        Image(systemName: "envelope.badge.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                        Text("Sprawdź skrzynkę mailową i kliknij link potwierdzający, aby aktywować konto.")
                            .foregroundStyle(.white)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                        Button {
                            withAnimation {
                                auth.oczekujeNaPotwierdzenieMaila = false
                                tryb = .logowanie
                            }
                        } label: {
                            Text("Już potwierdziłem — zaloguj się")
                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.8))
                                .underline()
                        }
                    }
                } else if resetWyslany {
                    Text("Wysłaliśmy link do zresetowania hasła na Twój adres e-mail.")
                        .foregroundStyle(.white)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                } else if let error = localError ?? auth.errorMessage {
                    Text(error)
                        .foregroundStyle(.yellow)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }

                Button {
                    Task { await zatwierdz() }
                } label: {
                    Group {
                        if auth.isLoading {
                            ProgressView()
                                .tint(.accent)
                        } else {
                            Text(tryb == .logowanie ? "Zaloguj się" : "Zarejestruj się")
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
                    withAnimation {
                        tryb = tryb == .logowanie ? .rejestracja : .logowanie
                        auth.errorMessage = nil
                        localError = nil
                        resetWyslany = false
                        potwierdzHaslo = ""
                    }
                } label: {
                    Text(tryb == .logowanie ? "Nie masz konta? Zarejestruj się" : "Masz już konto? Zaloguj się")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.8))
                }

                Spacer()
            }
            .padding(.horizontal, 30)
    }

    // MARK: - Akcje

    private func zatwierdz() async {
        localError = nil
        resetWyslany = false
        if tryb == .rejestracja {
            guard password.count >= 6 else {
                localError = "Hasło musi mieć co najmniej 6 znaków."
                return
            }
            guard password == potwierdzHaslo else {
                localError = "Hasła nie są zgodne."
                return
            }
        }
        if tryb == .logowanie {
            await auth.signIn(email: email, password: password)
        } else {
            await auth.signUp(email: email, password: password)
        }
    }

    private func wyslijReset() async {
        localError = nil
        resetWyslany = false
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            localError = "Podaj swój adres e-mail powyżej."
            return
        }
        let ok = await auth.resetPassword(email: trimmed)
        if ok {
            withAnimation { resetWyslany = true }
        }
    }
}

#Preview {
    AuthLogowanie_V()
}
