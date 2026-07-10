
import SwiftData
import SwiftUI

struct DrinkPrzepis_V: View {
	@Environment(\.modelContext) private var modelContext
	@StateObject private var auth = AuthService_VM.shared

	@Binding var drink: Dr_M

	@State private var isEditing = false

	var body: some View {
		ZStack {
			VStack(alignment: .leading) {
				HStack {
					Text("Przepis:")
						.TitleStyle()
						.textCase(.uppercase)
					
					Spacer()

					// Edycja: admin — wszystkie przepisy; Premium — tylko własne
					if auth.mozeEdytowac(drink) {
						Button(action: {
							let konczeEdycje = isEditing
							withAnimation {
								isEditing.toggle()
							}
							// Admin edytujący treść serwerową → wypchnij kroki na serwer (dla wszystkich)
							if konczeEdycje && auth.isAdmin && drink.drZrodlo != "Własny" {
								Task { await pushKrokiAdmin(drink: drink) }
							}
						}) {
							Text(isEditing ? "Gotowe" : "Edytuj")
						}
					}
				}
				
				List {
					ForEach(drink.drPrzepis) { linia in
						HStack(alignment: .top) {
							Image(systemName: linia.przepOpcja
									? "\(linia.przepNo).circle"
									: "\(linia.przepNo).circle.fill")
							.foregroundColor(linia.przepOpcja ? .secondary : .accentColor)
							.font(.headline)

							if isEditing {
								VStack(alignment: .leading, spacing: 6) {
									// Pole wieloliniowe — rośnie z treścią kroku
									TextField("Opis kroku", text: Binding(
										get: { linia.przepOpis },
										set: { linia.przepOpis = $0 }
									), axis: .vertical)
									.textFieldStyle(.roundedBorder)
									.lineLimit(1...6)

									Toggle("Krok opcjonalny", isOn: Binding(
										get: { linia.przepOpcja },
										set: { linia.przepOpcja = $0 }
									))
									.font(.caption)
									.tint(.secondary)
								}
							} else {
								Text(linia.przepOpis)
									.fontWeight(.light)
									.foregroundStyle(!linia.przepOpcja ? Color.primary : Color.secondary)
								Spacer()
							}
						}
						.listRowBackground(Color.clear)
					}
					.onDelete(perform: deletePrzepis)
					.onMove(perform: movePrzepis)
					
					if isEditing {
						Button {
							addPrzepis()
						} label: {
							Label("Dodaj pozycję do przepisu", systemImage: "plus.circle.fill")
						}
						.listRowBackground(Color.clear)
					}
				}
				.listStyle(.plain)
				
				if !drink.drUwagi.isEmpty {
					Divider()
					Text(drink.drUwagi)
				}
			}
			.padding(20)
			.background(
				RoundedRectangle(cornerRadius: 12)
					.foregroundStyle(.regularMaterial))
		}
	}
	
		// MARK: - Dodawanie nowego przepisu
	private func addPrzepis() {
		let nowy = DrPrzepis_M(
			relacjaDrink: drink,
			drinkID: drink.id,
			przepNo: drink.drPrzepis.count + 1,
			przepOpis: "Nowy krok",
			przepOpcja: false
		)
		modelContext.insert(nowy)
	}
	
		// MARK: - Usuwanie
	private func deletePrzepis(at offsets: IndexSet) {
		for index in offsets {
			let przepis = drink.drPrzepis[index]
			modelContext.delete(przepis)
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
			updateNumeracja()
		}
	}
	
		// MARK: - Przesuwanie
	private func movePrzepis(from source: IndexSet, to destination: Int) {
		var reordered = drink.drPrzepis
		reordered.move(fromOffsets: source, toOffset: destination)
		
		for (index, item) in reordered.enumerated() {
			item.przepNo = index + 1
		}
	}
	
		// MARK: - Aktualizacja numeracji
	private func updateNumeracja() {
		let sorted = drink.drPrzepis.sorted { $0.przepNo < $1.przepNo }
		for (i, item) in sorted.enumerated() {
			item.przepNo = i + 1
		}
	}
}

#Preview {
	DrinkPrzepis_V(drink: Binding.constant(drMock()) )
}

