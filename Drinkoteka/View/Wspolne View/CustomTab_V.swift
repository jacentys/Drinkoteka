// Główny kontener z własnym paskiem zakładek. Tu też następuje przeładowanie
// treści przy zmianie języka (zsynchronizujJezyk), niezależnie od aktywnej zakładki.
import SwiftUI
import SwiftData

	/// Taby aplikacji
enum Tab: String, CaseIterable {
	case home
	case drinki
	case skladniki
	case opcje

	var tytul: String {
		switch self {
			case .home: return "Główna"
			case .drinki: return "Drinki"
			case .skladniki: return "Składn."
			case .opcje: return "Opcje"
		}
	}

	var systemImage: String {
		switch self {
			case .home:
				return "house"
			case .drinki:
				return "wineglass"
			case .skladniki:
				return "waterbottle"
			case .opcje:
				return "gearshape"
		}
	}

	var index: Int {
		return Tab.allCases.firstIndex(of: self) ?? 0
	}
}

struct CustomTab_V: View {
	/// View Properties
	@State private var activeTab: Tab = .home
	/// Wcelu ułagodzenia animacji slide, używamy pasującego efektu geometrii.
	@Namespace private var animation
	@State var tabShapePosition: CGPoint = .zero

	@Environment(\.modelContext) private var modelContext
	@AppStorage("jezykAplikacji") private var jezykAplikacji: String = "pl"
	@AppStorage("setupDone") private var setupDone: Bool = false
	// Domyślnie true dla instalacji sprzed tego ekranu (setupDone już ustawione) —
	// nie pokazujemy onboardingu wstecznie użytkownikom, którzy już korzystają z apki.
	@AppStorage("jezykWybranyPrzezUzytkownika") private var jezykWybrany: Bool = UserDefaults.standard.bool(forKey: "setupDone")
	@State private var przeladowujeJezyk: Bool = false
	@State private var bladPolaczenia: Bool = false

    var body: some View {
		 ZStack {
			 // Ekran wyboru języka — pokazywany raz, przed pierwszym pobraniem treści,
			 // żeby dane od razu ładowały się w wybranym języku.
			 if !jezykWybrany {
				 JezykWyboru_V { wybrany in
					 jezykAplikacji = wybrany
					 jezykWybrany = true
				 }
				 .transition(.opacity)
			 } else
			 // TabView renderujemy TYLKO gdy dane są gotowe i nie trwa przeładowanie.
			 // Podczas pierwszego ładowania i zmiany języka (delAll + reload) widoki
			 // z @Query są usuwane z hierarchii, żeby nie sięgały do kasowanych
			 // obiektów SwiftData (inaczej crash "backing data could no longer be found").
			 if setupDone && !przeladowujeJezyk {
				 VStack(spacing: 0) {
					 TabView(selection: $activeTab) {
						 Home_V(activeTab: $activeTab)
							 .tag(Tab.home)
							 .toolbar(.hidden, for: .tabBar)
						 DrinkiLista_V()
							 .tag(Tab.drinki)
#if os(iOS)
							 .toolbar(.hidden, for: .tabBar)
#endif
						 Text("Skladniki")
						 SkladnikiLista_V()
							 .tag(Tab.skladniki)
#if os(iOS)
							 .toolbar(.hidden, for: .tabBar)
#endif
						 Preferencje_V()
							 .tag(Tab.opcje)
#if os(iOS)
							 .toolbar(.hidden, for: .tabBar)
#endif
					 }
					 CustomTabBar()
				 }
				 .transition(.opacity)
			 } else {
				 // Loader: offline z ponowieniem tylko przy pierwszym ładowaniu
				 LadowanieEkran_V(blad: bladPolaczenia && !setupDone) {
					 Task { await wykonajPierwszeLadowanie() }
				 }
				 .transition(.opacity)
			 }
		 }
		 .animation(.easeInOut(duration: 0.3), value: setupDone)
		 .animation(.easeInOut(duration: 0.3), value: przeladowujeJezyk)
		 .animation(.easeInOut(duration: 0.3), value: jezykWybrany)
		 // Pierwsze pobranie treści czeka na wybór języka, żeby dane od razu
		 // ładowały się w wybranym języku (patrz JezykWyboru_V).
		 .task(id: jezykWybrany) {
			 guard jezykWybrany else { return }
			 await pierwszeLadowanie()
		 }
		 // Krok 1: decyzja — czy potrzebne przeładowanie treści w nowym języku.
		 // Ustawienie flagi usuwa TabView z hierarchii (patrz body).
		 .task(id: jezykAplikacji) {
			 guard UserDefaults.standard.bool(forKey: "setupDone") else {
				 UserDefaults.standard.set(jezykAplikacji, forKey: "dataLang")
				 return
			 }
			 let dataLang = UserDefaults.standard.string(forKey: "dataLang") ?? "pl"
			 if dataLang != jezykAplikacji { przeladowujeJezyk = true }
		 }
		 // Krok 2: właściwe przeładowanie — odpala się w OSOBNYM cyklu, gdy TabView
		 // jest już usunięty, więc delAll nie unieważnia obserwowanych obiektów.
		 //
		 // Pętla (nie pojedynczy przebieg) jest tu celowa: `przeladowujeJezyk` to
		 // zwykły Bool, więc gdyby użytkownik przełączył język drugi raz zanim ten
		 // task się skończy, ustawienie flagi z powrotem na true byłoby dla SwiftUI
		 // no-opem (`.task(id:)` odpala się tylko przy zmianie wartości) — drugie
		 // żądanie przeładowania po prostu by zginęło, a `dataLang` zostałby
		 // ustawiony na język, którego treść nigdy nie została wczytana (appka
		 // przestałaby wykrywać potrzebę kolejnego przeładowania). Pętla sprawdza
		 // po każdym przebiegu, czy jezykAplikacji zdążył się zmienić w trakcie,
		 // i jeśli tak — ładuje ponownie, zamiast gubić żądanie. TabView zostaje
		 // usunięty z hierarchii przez cały czas trwania pętli (nie tylko pojedynczego
		 // przebiegu), co eliminuje też ryzyko crasha z krótkiego przywrócenia
		 // TabView między dwoma szybko następującymi po sobie przeładowaniami.
		 .task(id: przeladowujeJezyk) {
			 guard przeladowujeJezyk else { return }
			 var celowyJezyk: String
			 repeat {
				 celowyJezyk = jezykAplikacji
				 await zmienJezykDanych(modelContext: modelContext)
				 await loadNotesFromSupabase(modelContext: modelContext)
				 // Odpalane tutaj (nie tylko w DrinkiLista_V), bo TabView bywa usunięty
				 // z hierarchii podczas przeładowania — jeśli użytkownik nie jest akurat
				 // na zakładce Drinki, jej .task mógłby się nie odpalić od razu.
				 await loadFavoritesFromSupabase(modelContext: modelContext)
				 await loadIngredientStockFromSupabase(modelContext: modelContext)
			 } while celowyJezyk != jezykAplikacji
			 UserDefaults.standard.set(celowyJezyk, forKey: "dataLang")
			 przeladowujeJezyk = false
		 }
	 }

		 // MARK: - PIERWSZE ŁADOWANIE DANYCH (w korzeniu, niezależnie od zakładki)
	 private func pierwszeLadowanie() async {
		 guard !setupDone else { return }
		 await wykonajPierwszeLadowanie()
	 }

	 private func wykonajPierwszeLadowanie() async {
		 bladPolaczenia = false
		 await MainActor.run {
			 try? modelContext.delete(model: Skl_M.self)
			 try? modelContext.delete(model: Dr_M.self)
			 try? modelContext.save()
		 }
		 let ok = await loadFromSupabase(modelContext: modelContext)
		 if ok {
			 UserDefaults.standard.set(jezykAplikacji, forKey: "dataLang")
			 setupDone = true                // ukrywa loader (z animacją)
		 } else {
			 bladPolaczenia = true
		 }
	 }

		///Custom TabBar - z większą ilością customizacji
	@ViewBuilder
	func CustomTabBar(_ tint: Color = Color.accent, _ inactiveColor: Color = Color.secondary) -> some View {
		/// Przesunięcie wszystkich pozostałych tabów na dół
		HStack(alignment: .bottom, spacing: 0) {
			ForEach(Tab.allCases, id: \.rawValue) {
				TabItem(
					tint: tint,
					inactiveTint: inactiveColor,
					tab: $0,
					animation: animation,
					activeTab: $activeTab,
					position: $tabShapePosition
				)
			}
		}
		.padding(.horizontal, 15)
		.padding(.vertical, 10)
		.padding(.top, -25)
		.background(content: {
			TabShape(midpoint: tabShapePosition.x)
				.foregroundStyle(.regularMaterial)
				.ignoresSafeArea()
				/// Dodanie blura i cienia
				.shadow(color: tint.opacity(0.2), radius: 10, x: 0, y: -10)
				.blur(radius: 1)
		})
///		Dodajemy animację
		.animation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7), value: activeTab)
	}
}


	/// Tab Bar Item
struct TabItem: View {
	var tint: Color
	var inactiveTint: Color
	var tab: Tab
	var animation: Namespace.ID
	@Binding var activeTab: Tab
	@Binding var position: CGPoint

		/// Pozycje wszystkich pozycji menu na ekranie
	@State private var tabPosition: CGPoint = .zero

	var body: some View {
		VStack(spacing: 5) {
			Image(systemName: tab.systemImage)
				.font(.title2)
				.foregroundStyle(activeTab == tab ? .white : inactiveTint)
				/// Zwiększenie wielkości dla Active Tab
				.frame(width: activeTab == tab ? 58 : 35, height: activeTab == tab ? 58 : 35)
				.background {
					if activeTab == tab {
						Circle()
							.fill(tint.gradient)
							.matchedGeometryEffect(id: "ACTIVETAB", in: animation)
					}
				}

			Text(LocalizedStringKey(tab.tytul))
				.font(.callout)
				.foregroundStyle(activeTab == tab ? tint : .gray)
		}
		.frame(maxWidth: .infinity)
		.contentShape((Rectangle()))
		.viewPosition(completion: { rect in
			tabPosition.x = rect.midX

				/// Update pozycję tab
			if activeTab == tab {
				position.x = rect.midX
			}
		})
		.onTapGesture {
			activeTab = tab

			withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
				position.x = tabPosition.x
			}
		}
	}
}


	/// Customowe `View Extension
	/// które zwróci View Position
	///
struct PositionKey: PreferenceKey {
	static var defaultValue: CGRect = .zero

	static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
		value = nextValue()
	}
}

extension View {
	@ViewBuilder
	func viewPosition(completion: @escaping (CGRect) -> ()) -> some View {
		self
			.overlay {
				GeometryReader {
					let rect = $0 .frame(in: .global)
					Color.clear
						.preference(key: PositionKey.self, value: rect)
						.onPreferenceChange(PositionKey.self, perform: completion)
				}
			}
	}
}


	/// Custom Tab Shape
struct TabShape: Shape {
	var midpoint: CGFloat

		/// Dodanie animacji przesuwania
	var animatableData: CGFloat {
		get { midpoint }
		set { midpoint = newValue }
	}

	func path(in rect: CGRect) -> Path {
		return Path { path in

				/// Najpierw rysujemy rectangle
			path.addPath(Rectangle().path(in: rect))

				/// Teraz rysujemy wygiętą krzywą
			path.move(to: .init(x: midpoint - 100, y: 0))

			let to = CGPoint(x: midpoint, y: -25)
			let to1 = CGPoint(x: midpoint + 100, y: 0)

			let control1 = CGPoint(x: midpoint - 25, y: 0)
			let control2 = CGPoint(x: midpoint - 25, y: -25)
			let control3 = CGPoint(x: midpoint + 25, y: -25)
			let control4 = CGPoint(x: midpoint + 25, y: 0)

			path.addCurve(to: to, control1: control1, control2: control2)
			path.addCurve(to: to1, control1: control3, control2: control4)
		}
	}
}



// MARK: - Ekran ładowania (animowany)

struct LadowanieEkran_V: View {
	var blad: Bool = false
	var ponow: () -> Void = {}

	@State private var puls = false

	var body: some View {
		ZStack {
			// Tło marki (spójne z Launch Screen i ikoną)
			LinearGradient(
				colors: [Color(red: 1.0, green: 0.42, blue: 0.06),
						 Color(red: 0.85, green: 0.33, blue: 0.0)],
				startPoint: .top, endPoint: .bottom)
			.ignoresSafeArea()

			VStack(spacing: 22) {
				Image(systemName: "wineglass.fill")
					.font(.system(size: 92))
					.foregroundStyle(.white)
					.scaleEffect(puls ? 1.06 : 0.94)
					.animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: puls)

				Text("Drinkotheque")
					.font(.largeTitle).fontWeight(.bold)
					.foregroundStyle(.white)

				if blad {
					// Stan offline z możliwością ponowienia
					VStack(spacing: 12) {
						Image(systemName: "wifi.slash")
							.font(.title)
							.foregroundStyle(.white.opacity(0.9))
						Text("Brak połączenia z internetem")
							.font(.headline).foregroundStyle(.white)
						Text("Przy pierwszym uruchomieniu potrzebne jest połączenie, aby pobrać przepisy.")
							.font(.footnote).foregroundStyle(.white.opacity(0.85))
							.multilineTextAlignment(.center)
							.padding(.horizontal, 40)
						Button(action: ponow) {
							Text("Spróbuj ponownie")
								.font(.headline).foregroundStyle(Color(red: 1, green: 0.4, blue: 0))
								.padding(.horizontal, 24).padding(.vertical, 12)
								.background(.white).clipShape(Capsule())
						}
						.padding(.top, 4)
					}
					.padding(.top, 8)
				} else {
					// Delikatna animacja „fali” z trzech kropek
					HStack(spacing: 10) {
						ForEach(0..<3, id: \.self) { i in
							Circle()
								.fill(.white)
								.frame(width: 11, height: 11)
								.scaleEffect(puls ? 1.0 : 0.5)
								.opacity(puls ? 1.0 : 0.4)
								.animation(.easeInOut(duration: 0.6).repeatForever()
									.delay(Double(i) * 0.18), value: puls)
						}
					}
					.padding(.top, 6)

					Text("Pobieram przepisy…")
						.font(.footnote).foregroundStyle(.white.opacity(0.85))
				}
			}
		}
		.onAppear { puls = true }
	}
}

#Preview {
	CustomTab_V()
}

#Preview("Ładowanie") {
	LadowanieEkran_V()
}
