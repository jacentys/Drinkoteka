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
					 .autocorrectionDisabled(true)
					 .disableAutocorrection(true)
#if os(iOS)
					 .textInputAutocapitalization(.never)
					 .autocapitalization(.none)
#endif
					 .overlay(
						Image(systemName: "xmark.circle.fill")
							.padding()
							.offset(x: 10)
							.foregroundColor(Color.primary)
							.opacity(searchText.isEmpty ? 0.0 : 1.0)
							.onTapGesture {
#if os(iOS)
								UIApplication.shared.koniecEdycjiExt()
#endif
								searchText = ""
							}
						
						,alignment: .trailing
					 )
			 }
			 .font(.headline)
			 .padding(10)
		 }
		
    }
}

#Preview {
	Group {
		SearchBar_V(searchText: .constant(""))
			.preferredColorScheme(.light)
		
		SearchBar_V(searchText: .constant(""))
			.preferredColorScheme(.dark)
		
	}
}
