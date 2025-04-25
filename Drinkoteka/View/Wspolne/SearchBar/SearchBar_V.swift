import SwiftUI

struct SearchBar_V: View {
	@Binding var searchText: String
    var body: some View {
		 VStack{
			 HStack {
				 Image(systemName: "magnifyingglass")
					 .foregroundColor(
						searchText.isEmpty ?
						Color.secondary : Color.accent
					 )
				 
				 TextField("Szukaj...", text: $searchText)
					 .foregroundColor(Color.primary)
					 .autocapitalization(.none)
					 .disableAutocorrection(true)
					 .overlay(
						Image(systemName: "xmark.circle.fill")
							.padding()
							.offset(x: 10)
							.foregroundColor(Color.primary)
							.opacity(searchText.isEmpty ? 0.0 : 1.0)
							.onTapGesture {
								UIApplication.shared.koniecEdycjiExt()
								searchText = ""
							}
						
						,alignment: .trailing
					 )
			 }
			 .font(.headline)
			 .padding(10)
//			 .background(
//				RoundedRectangle(cornerRadius: 8)
//					.fill(Color.white)
//					.shadow(
//						color: Color.accent.opacity(0.15),
//						radius: 10, x: 0, y: 0)
//			 )
		 }
		
    }
}

#Preview {
	Group {
		SearchBar_V(searchText: .constant(""))
//			.previewLayout(.sizeThatFits)
			.preferredColorScheme(.light)
		
		SearchBar_V(searchText: .constant(""))
//			.previewLayout(.sizeThatFits)
			.preferredColorScheme(.dark)
		
	}
}
