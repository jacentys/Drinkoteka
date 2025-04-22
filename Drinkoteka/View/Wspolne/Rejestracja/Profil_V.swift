//
//  Profil_V.swift
//  Drinkoteka
//
//  Created by Jacek Skrobisz on 2025.04.22.
//

import SwiftUI

struct Profil_V: View {

	@AppStorage("zalogowany") var zalogowany: Bool?
	@AppStorage("uzytkownik") var uzytkownik: String?

    var body: some View {
		 VStack {
			 Image(systemName: "person.circle.fill")
				 .resizable()
				 .scaledToFit()
				 .frame(width: 100, height: 100)
				 .padding(.top, 50)
			  Text(uzytkownik ?? "Brak danych")
				 .font(.title)
				 .fontWeight(.semibold)
				 .padding(.bottom, 70)
			 Text("Wyrejestruj")
				 .frame(maxWidth: .infinity)
				 .frame(height: 54)
				 .background(.black)
				 .foregroundColor(.yellow)
				 .font(.headline)
				 .cornerRadius(8)
				 .onTapGesture {
					 wyrejestrowanie()
				 }
		 }
		 .padding(.horizontal, 30)
		 .padding(.vertical, 50)
		 .background(.white)
		 .cornerRadius(20)
		 .shadow(radius: 8)
		 .foregroundColor(.accent)
		 .padding(30)
    }

	func wyrejestrowanie () {
		zalogowany = false
		uzytkownik = ""
	}

}

#Preview {
    Profil_V()
		.background(Back(kolor: .accent))
}
