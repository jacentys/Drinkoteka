import SwiftUI

struct SkladnikZamiennikiAll_V: View {

	@Bindable var skladnik: Skl_M

    var body: some View {
		 ZStack {

			 VStack(alignment: .leading) {
				 
				 
				 // MARK: NAGŁOWEK
				 HStack(alignment: .firstTextBaseline) {
					 Text("Zamiennik:".uppercased())
						 .TitleStyle()
					 
					 Spacer()
				 }
				 
					 // MARK: LISTA ZAMIENNIKÓW
				 ForEach (skladnik.sklZamArray, id: \.self) { zamiennik in
					 NavigationLink(destination: Skladnik_V(skladnik: zamiennik)) {
						 SkladnikZamiennikLinia_V(skladnik: zamiennik)
					 }
				 }
			 }
			 .frame(maxWidth: .infinity, alignment: .leading)
		 }
		 .padding(20)
		 .background(RoundedRectangle(cornerRadius: 12)
			.foregroundStyle(.regularMaterial))
    }
}

#Preview {
	NavigationStack {
		SkladnikZamiennikiAll_V(skladnik: sklMock())
	}
}

