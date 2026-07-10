import SwiftUI

struct Logowanie_V: View {
    @StateObject private var auth = AuthService_VM.shared

    var body: some View {
        if auth.isLoggedIn {
            AuthProfil_V()
        } else {
            AuthLogowanie_V()
        }
    }
}

#Preview {
    Logowanie_V()
}
