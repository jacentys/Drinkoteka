import SwiftUI

struct AuthLogowanie_V: View {
    @StateObject private var auth = AuthService_VM.shared

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var tryb: Tryb = .logowanie

    enum Tryb { case logowanie, rejestracja }

    var body: some View {
        ZStack {
            Back_V(kolor: .accent)
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
                        .padding()
                        .background(.white)
                        .cornerRadius(10)

                    SecureField("hasło...", text: $password)
                        .padding()
                        .background(.white)
                        .cornerRadius(10)
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
                } else if let error = auth.errorMessage {
                    Text(error)
                        .foregroundStyle(.yellow)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }

                Button {
                    Task {
                        if tryb == .logowanie {
                            await auth.signIn(email: email, password: password)
                        } else {
                            await auth.signUp(email: email, password: password)
                        }
                    }
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
    }
}

#Preview {
    AuthLogowanie_V()
}
