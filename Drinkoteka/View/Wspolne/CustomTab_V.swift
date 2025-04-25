import SwiftUI

	/// Taby aplikacji
enum Tab: String, CaseIterable {
//	case home = "Home"
	case drinki = "Drinki"
	case skladniki = "Składn."
	case opcje = "Opcje"

	var systemImage: String {
		switch self {
//			case .home:
//				return "house"
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
	@State private var activeTab: Tab = .drinki
	/// Wcelu ułagodzenia animacji slide, używamy pasującego efektu geometrii.
	@Namespace private var animation
	@State var tabShapePosition: CGPoint = .zero

    var body: some View {
		 VStack(spacing: 0) {
			 TabView(selection: $activeTab) {
//				 HomeView()
//					 .tag(Tab.home)
//					 // Ukrycie natywnego tab bar
//					 .toolbar(.hidden, for: .tabBar)
				 DrinkiLista_V()
					 .tag(Tab.drinki)
					 // Ukrycie natywnego tab bar
#if os(iOS)
					 .toolbar(.hidden, for: .tabBar)
#endif
				 Text("Skladniki")
				 skladniki()
					 .tag(Tab.skladniki)
					 // Ukrycie natywnego tab bar
#if os(iOS)
					 .toolbar(.hidden, for: .tabBar)
#endif
				 Preferencje_V()
					 .tag(Tab.opcje)
					 // Ukrycie natywnego tab bar
#if os(iOS)
					 .toolbar(.hidden, for: .tabBar)
#endif
			 }
			 CustomTabBar()
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

			Text(tab.rawValue)
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



#Preview {
	CustomTab_V()
}
