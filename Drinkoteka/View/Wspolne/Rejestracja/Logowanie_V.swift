import SwiftUI

struct Logowanie_V: View {

	@AppStorage("zalogowany") var zalogowany: Bool = false

    var body: some View {
		 ZStack {
			 Back(kolor: .accent)

			 if zalogowany {
				 Profil_V()
			 } else {
				 Rejestracja_v()
			 }


		 }
    }
}

#Preview {
    Logowanie_V()
}
