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
					viewKategoria(kat: skladnik.sklKat.rawValue)
					viewProcenty(proc: skladnik.sklProc)
					viewKalorie(kal: skladnik.sklKal)
//					viewMiara(miara: skladnik.sklMiara)
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
	SkladnikTitle_V(skladnik: sklMock())
}
