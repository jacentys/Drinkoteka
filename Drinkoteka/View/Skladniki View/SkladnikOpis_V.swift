import SwiftUI

struct SkladnikOpis_V: View {

	@Bindable var skladnik: Skl_M
	@State private var edytujOpis = false
	
	var body: some View {
			ZStack {
				
				VStack(alignment: .leading) {
					HStack(alignment: .firstTextBaseline) {



							// MARK: Nagłówek
						Text("Opis:".uppercased())
							.TitleStyle()
						
						Spacer ()
					}

						// MARK: TEKST OPISU
					Text(skladnik.sklOpis)
						.multilineTextAlignment(.leading)
				}
				.frame(maxWidth: .infinity)
			}
			.padding(20)
			.background(RoundedRectangle(cornerRadius: 12)
				.foregroundStyle(.regularMaterial))			
	}
}

#Preview {
	NavigationStack{
		Text("test")
//		SkladnikOpisView(sklSelID: "amaretto")
	}
}
