import SwiftUI

struct Rejestracja_v: View {

	@State var onboarding: Int = 0
	@State var nick: String = ""
	@State var eMail: String = ""
	@State var pelnoletni: Bool = false
	let transition: AnyTransition = .slide
	@State var alertTitle: String = ""
	@State var alertPokaz: Bool = false

	@AppStorage("zalogowany") var zalogowany: Bool?
	@AppStorage("uzytkownik") var uzytkownik: String?
	@AppStorage("uzytkownikMail") var uzytkownikMail: String?

	var body: some View {
		ZStack {
				// Zawartość
			ZStack{
				switch onboarding {
					case 0:
						sekcjaPowitalna
							.transition(transition)
					case 1:
						podajDane
							.transition(transition)
					case 2:
						sekcjaPelnoletnosci
							.transition(transition)
					default:
						Text("Default")
				}
			}
				// przyciski
			VStack {
				Spacer()
				przyciskDolny
			}
			.padding(30)
		}
		.alert(isPresented: $alertPokaz, content: {
			return Alert(title: Text(alertTitle))
		})
	}
}

#Preview {
    Rejestracja_v()
		.background(Back_V(kolor: .accent))
}

// MARK: KOMPONENTY
extension Rejestracja_v {

	private var przyciskDolny: some View {
		Text(onboarding == 0 ? "Zarejestruj się" : onboarding == 3 ? "Koniec" : "Następny")
			.font(.headline)
			.foregroundStyle(.accent)
			.frame(height: 54)
			.frame(maxWidth: .infinity)
			.background(.white)
			.cornerRadius(12)
			.shadow(radius: 10)
			.onTapGesture {
				buttonNacisniety()
			}
	}

	private var sekcjaPowitalna: some View {
		VStack(spacing: 40) {
			Image(systemName: "heart.text.square.fill")
				.resizable()
				.scaledToFit()
				.frame(width: 150, height: 150, alignment: .center)
				.foregroundStyle(.white.gradient)
			Text("Poszukaj swoich smaków")
				.font(.title)
				.foregroundStyle(.white)
			Divider()
			Text("W tej aplikacji znajdziesz przepisy na drinki. Zarówno alkoholowe jak i bezaklkoholowe. Możesz wyszukiwać ich filtrując poziom słodkości, moc drinka oraz podstawowy użyty alkohol. Oprócz tego po zaznaczeniu które składniki posiadasz aplikacja pokaże Ci które drinki możesz zrobić, lub ile składników brakuje w poszczególnych drinkach.")
				.multilineTextAlignment(.center)
				.foregroundStyle(.white)
			Divider()
		}
		.padding(30)
	}

	private var podajDane: some View {
		VStack(spacing: 20) {
			Image(systemName: "heart.text.square.fill")
				.resizable()
				.scaledToFit()
				.frame(width: 150, height: 150, alignment: .center)
				.foregroundStyle(.white)
				.shadow(radius: 3)
			Divider()
			Text("Podaj swoje dane")
				.font(.title)
				.fontWeight(.semibold)
				.foregroundStyle(.white)
			TextField("Imię lub nick...", text: $nick)
				.font(.headline)
				.frame(height: 54)
				.padding(.horizontal)
				.background(.white)
				.foregroundStyle(.accent)
				.cornerRadius(8)
			TextField("e-mail...", text: $eMail)
				.font(.headline)
				.frame(height: 54)
				.padding(.horizontal)
				.background(.white)
				.foregroundColor(.accent)
				.cornerRadius(8)
				.disableAutocorrection(true)
#if os(iOS)
				.keyboardType(.emailAddress)   // Sets the keyboard type
				.autocapitalization(.none)     // Disables auto-capitalization
#endif
			Divider()
		}
		.padding(30)
	}

	private var sekcjaPelnoletnosci: some View {
		VStack {
			Toggle("Mam 18 lat", isOn: $pelnoletni)
				.foregroundColor(.gray)
				.accentColor(.accent)
		}
		.padding(30)
	}
}

// MARK: FUNKCJE
extension Rejestracja_v {
	func buttonNacisniety () {
		// Sprawdzenie danych
		switch onboarding {
			case 1:
				guard nick.count >= 3 else {
					pokazAlert("Wpisz imię lub nick")
					return
				}
//				guard isEmail(uzytkownikMail) else {
//					pokazAlert("Wpisz e-mail w poprawnym formacie.")
//					return
//				}
			case 2:
				guard pelnoletni else {
					pokazAlert("Aby używać tej aplikacji musisz być pełnoletni!")
					return
				}
			default:
				break
		}

		// do następnego ekranu
		if onboarding == 3 {
			zarejestrowano()
		} else {
			withAnimation(.spring) {
				onboarding += 1
			}
		}
	}

	func zarejestrowano() {
		uzytkownik = nick
		uzytkownikMail = eMail
		zalogowany = true
	}

	func pokazAlert(_ tekst: String) {
		alertTitle = tekst
		alertPokaz.toggle()
	}

	func isEmail(_ adres: String?) -> Bool {
		if let adres = adres {
			let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
			return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: adres)
		}
		return false
	}
}
