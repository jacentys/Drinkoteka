import SwiftUI

struct SkladnikTitle_V: View {
	@Bindable var skladnik: Skl_M

	var body: some View {
		
		ZStack {
			VStack(spacing: 0) {
				VStack{
					HStack {
						Spacer()
						VStack {
							Text(skladnik.sklNazwa)
								.font(.title)
								.fontWeight(.black)
								.foregroundColor(Color.primary)
								.multilineTextAlignment(.center)
						}

						Spacer()
					}
				}  // MARK: NAZWA
				
				Divider().padding(4)
				
				HStack {
					Kategoria(kat: skladnik.sklKat.rawValue)
					Proc(proc: skladnik.sklProc)
					Kal(kal: skladnik.sklKal)
//					Miara(miara: skladnik.sklMiara)
				}
			}
			.shadow(color: .white, radius: 20)
		}
		.foregroundColor(Color.primary)
		.padding(20)
		.background(RoundedRectangle(cornerRadius: 12)
			.foregroundStyle(.regularMaterial)
			)
	}
}

#Preview {
	Text("Skladnik Title")
//	TitleView(nazwa: "Amaretto", proc: 20, kal: 130, miara: miaraEnum.galazka, kat: "alkochol")
}
