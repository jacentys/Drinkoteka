import SwiftData
import SwiftUI

struct skladniki: View {
	@Environment(\.modelContext) private var modelContext
	
	@Query(sort: [SortDescriptor(\Skl_M.sklNazwa)])
	private var wszystkieSkladniki: [Skl_M]
	
	@State private var tekstFiltru: String = ""
	
	var przefiltrowaneSkladniki: [Skl_M] {
		if tekstFiltru.isEmpty {
			return wszystkieSkladniki
		} else {
			return wszystkieSkladniki.filter {
				$0.sklNazwa.localizedCaseInsensitiveContains(tekstFiltru)
			}
		}
	}
	
	var body: some View {
		NavigationSplitView {
			Text("\(przefiltrowaneSkladniki.count)")
			VStack {
				TextField("Szukaj drinka...", text: $tekstFiltru)
					.textFieldStyle(.roundedBorder)
					.padding()
				List {
					ForEach(przefiltrowaneSkladniki) { skladnik in
						NavigationLink {
							VStack{
								List {
									Text("Nazwa: \(skladnik.sklNazwa)")
										.font(.headline)
									Text("Kat.: \(skladnik.sklKat.opis)")
									Text("Proc.: \(skladnik.sklProc)")
									Text("Kolor: \(skladnik.sklKolor)")
									Text("Foto: \(skladnik.sklFoto)")
									Text("Opis.: \(skladnik.sklOpis)")
									Text("Stan: \(skladnik.sklStan.opis)")
									Text("Kalorie: \(skladnik.sklKal)")
									Text("Miara: \(skladnik.sklMiara.opis)")
									Text("WWW: \(skladnik.sklWWW)")
									Text("Zamienniki: \(skladnik.sklZamArray)")
								}
								
								Divider()
								List {
									ForEach(skladnik.sklZamArray) { zamiennik in
											Text("\(zamiennik.sklNazwa)")
									}
								}
							}
						} label: {
							Text("\(skladnik.sklNazwa)")
						}
					}
					.onDelete(perform: delSkladnik)
				}
			}
			.onAppear {
				print("Początek onAppear: \(UserDefaults.standard.bool(forKey: "setupDone"))")
				
				if !UserDefaults.standard.bool(forKey: "setupDone")
				{
					delAll()
					loadSklCSV_V(modelContext: modelContext)
					loadSklZamiennikiCSV_V(modelContext: modelContext)
					UserDefaults.standard.set(true, forKey: "setupDone")
				}
				print("Koniec onAppear: \(UserDefaults.standard.bool(forKey: "setupDone"))")
			}
#if os(macOS)
			.navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
			.toolbar {
#if os(iOS)
				ToolbarItem(placement: .navigationBarTrailing) {
					EditButton()
				}
#endif
				ToolbarItem {
					Button(action: {
						delAll()
						loadSklCSV_V(modelContext: modelContext)
						loadSklZamiennikiCSV_V(modelContext: modelContext)
					}) { Image(systemName: "restart.circle.fill") }
					
					Button(action: addZam) {
						Label("Add Zamiennik", systemImage: "plus")
					}
				}
			}
		} detail: {
			Text("Wybierz")
		}
	}
	
	private func addZam() {
		print("Funkcja addZam uruchomiona")
		withAnimation {
			let zam = SklZamiennik(skladnikID: "SkładnikID", zamiennikID: "ID zamiennika")
			modelContext.insert(zam)
		}
	}
	
	private func delSkladnik(offsets: IndexSet) {
		withAnimation {
			for index in offsets {
				print("Funkcja delSkladnik \(przefiltrowaneSkladniki[index].sklNazwa) uruchomiona")
				modelContext.delete(przefiltrowaneSkladniki[index])
			}
		}
	}
	
	func delAll() {
		print("Funkcja delAll uruchomiona")
		do {
			try modelContext.delete(model: Skl_M.self)
		} catch {
			print("Błąd przy usuwaniu skladnikow: \(error)")
		}
	}
}




#Preview {
	NavigationStack {
		skladniki()
	}
	.modelContainer(for: Skl_M.self, inMemory: true)
}
