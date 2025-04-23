import SwiftUI

struct SkladnikStan_V: View {

	@Bindable var skladnik: Skl_M

	let wielkoscIkon: CGFloat = 20
	let wielkoscKolka: CGFloat = 50
	
	var body: some View {
		
		ZStack {

			HStack { // MARK: ALL
				
				Spacer()
				
				// MARK: IN BAR BUTTON
				VStack {
					Text("W barku:".uppercased())
						.font(.headline)
					IkonaJestBrak_V(skladnik: skladnik, txtShow: false)
				}
				
				Spacer()
				
			} // END ALL
		}
		.padding(20)
		.background(RoundedRectangle(cornerRadius: 12)
			.foregroundStyle(.regularMaterial))
	}
}

#Preview {
	NavigationStack {
		Text("test")
//		SkladnikStanView(skladnik: skladnik)
	}
}
