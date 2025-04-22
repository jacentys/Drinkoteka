import SwiftUI

struct DrinkTitle_V: View {
	@Bindable var drink: Dr_M

	var body: some View {
		
		ZStack {
			VStack(spacing: 0) {
				VStack{
					HStack {
						Spacer()
						VStack {
							Text(drink.drNazwa)
								.font(.title)
								.fontWeight(.black)
								.foregroundColor(Color.primary)
								.multilineTextAlignment(.center)
							Text(drink.drZrodlo)
								.font(.footnote)
								.foregroundStyle(.secondary)
						}

						Spacer()
					}
				}  // MARK: NAZWA
				
				Divider().padding(4)
				
				HStack {
					Kategoria(kat: drink.drKat.rawValue)
					Proc(proc: drink.drProc)
//					Miara(miara: drink.drMiara)
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
	Text("DrinkTitle")
//	TitleView(nazwa: "Amaretto", proc: 20, kal: 130, miara: miaraEnum.galazka, kat: "alkochol")
}

	// MARK: KATEGORIA
struct Kategoria: View {
	var kat: String
	var body: some View {
		HStack {
			if kat != "" {
				HStack(alignment: .lastTextBaseline, spacing: 0) {
					Text("kat.: ")
						.font(.caption)
						.fontWeight(.light)
						.fontWidth(.condensed)
					
					Text("\(kat) ")
						.font(.headline)
						.fontWeight(.black)
						.fontWidth(.condensed)
				}
			}
		}
		.foregroundStyle(Color.secondary)
	}
} // KATEGORIA

// MARK: PROC
struct Proc: View {
	var proc: Int
	var body: some View {
		HStack(alignment: .lastTextBaseline, spacing: 0) {
			
			Text("alk.:")
				.font(.caption)
				.fontWeight(.light)
				.fontWidth(.condensed)
			
			Text("\(proc)%")
				.font(.headline)
				.fontWeight(.black)
				.fontWidth(.condensed)
			
		}
		.foregroundColor(Color.secondary)
	}
} // PROC

// MARK: KAL
struct Kal: View {
	
	let kal: Int
	
	var body: some View {
		
		HStack(alignment: .lastTextBaseline, spacing: 0) {
			
			Text("kCal.:")
				.font(.caption)
				.fontWeight(.light)
				.fontWidth(.condensed)
			
			Text("\(kal)")
				.font(.headline)
				.fontWeight(.black)
				.fontWidth(.condensed)
		}
		.foregroundColor(Color.secondary)
	}
} // KAL

	// MARK: MIARA
struct Miara: View {
	var miara: miaraEnum
	var body: some View {
		if miara != miaraEnum.brak {
			HStack(alignment: .lastTextBaseline, spacing: 0) {
				Text("miara: ")
					.font(.caption)
					.fontWeight(.light)
					.fontWidth(.condensed)
				
				Text("\(miara.rawValue)".lowercased())
					.font(.headline)
					.fontWeight(.black)
					.fontWidth(.condensed)
			}
			.foregroundStyle(Color.secondary)
		}
	}
} // MIARA
