import SwiftUI
import SwiftData

// MARK: - Tymczasowe struktury do budowania listy przed zapisem

private struct NowyKrok: Identifiable {
    var id = UUID()
    var opis: String = ""
    var opcja: Bool = false
}

private struct NowySkladnik: Identifiable {
    var id = UUID()
    var skladnik: Skl_M
    var ilosc: Double = 0
    var miara: miaraEnum = .ml
    var info: String = ""
    var opcja: Bool = false
}

// MARK: - Główny widok

struct DrinkDodaj_V: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Skl_M.sklNazwa) private var wszystkieSkladniki: [Skl_M]

    // Podstawowe
    @State private var nazwa: String = ""
    @State private var kategoria: drKatEnum = .koktail
    @State private var slodycz: drSlodyczEnum = .brakDanych
    @State private var szklo: szkloEnum = .koktailowy
    @State private var procAlk: String = "0"
    @State private var notatka: String = ""
    @State private var uwagi: String = ""

    // Składniki
    @State private var skladniki: [NowySkladnik] = []
    @State private var pokazWyborSkladnika: Bool = false

    // Przepis
    @State private var kroki: [NowyKrok] = [NowyKrok()]

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Podstawowe
                Section(header: Text("Podstawowe")) {
                    TextField("Nazwa drinka", text: $nazwa)

                    Picker("Kategoria", selection: $kategoria) {
                        ForEach(drKatEnum.allCases, id: \.self) {
                            Text($0.opis).tag($0)
                        }
                    }

                    Picker("Słodycz", selection: $slodycz) {
                        ForEach(drSlodyczEnum.allCases, id: \.self) {
                            Text($0.opis).tag($0)
                        }
                    }

                    Picker("Szkło", selection: $szklo) {
                        ForEach(szkloEnum.allCases, id: \.self) {
                            Text($0.opis).tag($0)
                        }
                    }

                    HStack {
                        Text("Alkohol %")
                        Spacer()
                        TextField("0", text: $procAlk)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                    }
                }

                // MARK: Składniki
                Section(header: Text("Składniki")) {
                    ForEach($skladniki) { $skl in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(skl.skladnik.sklNazwa)
                                    .fontWeight(.medium)
                                Spacer()
                                Toggle("Opcjonalny", isOn: $skl.opcja)
                                    .labelsHidden()
                                    .tint(.secondary)
                            }
                            HStack(spacing: 8) {
                                TextField("Ilość", value: $skl.ilosc, format: .number)
                                    .keyboardType(.decimalPad)
                                    .frame(width: 60)
                                    .textFieldStyle(.roundedBorder)

                                Picker("", selection: $skl.miara) {
                                    ForEach(miaraEnum.allCases, id: \.self) {
                                        Text($0.opis).tag($0)
                                    }
                                }
                                .pickerStyle(.menu)

                                TextField("Info", text: $skl.info)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.caption)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                    .onDelete { skladniki.remove(atOffsets: $0) }
                    .onMove { skladniki.move(fromOffsets: $0, toOffset: $1) }

                    Button {
                        pokazWyborSkladnika = true
                    } label: {
                        Label("Dodaj składnik", systemImage: "plus.circle")
                    }
                }

                // MARK: Przepis
                Section(header: Text("Przepis")) {
                    ForEach($kroki) { $krok in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(kroki.firstIndex(where: { $0.id == krok.id }).map { $0 + 1 } ?? 0).")
                                .foregroundStyle(.secondary)
                                .frame(width: 20)
                            VStack(alignment: .leading, spacing: 4) {
                                TextField("Opis kroku", text: $krok.opis, axis: .vertical)
                                    .lineLimit(2...4)
                                Toggle("Opcjonalny", isOn: $krok.opcja)
                                    .font(.caption)
                                    .tint(.secondary)
                            }
                        }
                    }
                    .onDelete { kroki.remove(atOffsets: $0) }
                    .onMove { kroki.move(fromOffsets: $0, toOffset: $1) }

                    Button {
                        kroki.append(NowyKrok())
                    } label: {
                        Label("Dodaj krok", systemImage: "plus.circle")
                    }
                }

                // MARK: Notatki
                Section(header: Text("Notatki")) {
                    TextField("Notatka", text: $notatka, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Uwagi", text: $uwagi, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Nowy drink")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Dodaj") {
                        dodajDrink()
                        dismiss()
                    }
                    .disabled(nazwa.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $pokazWyborSkladnika) {
                WyborSkladnika_V(wszystkie: wszystkieSkladniki) { wybrany in
                    skladniki.append(NowySkladnik(skladnik: wybrany))
                }
            }
        }
    }

    private func dodajDrink() {
        let proc = Int(procAlk) ?? 0
        let drinkID = UUID().uuidString
        let drink = Dr_M(
            drinkID:    drinkID,
            drNazwa:    nazwa.trimmingCharacters(in: .whitespaces),
            drKat:      kategoria,
            drZrodlo:   "Własny",
            drKolor:    "",
            drFoto:     szklo.foto,
            drProc:     proc,
            drSlodycz:  slodycz,
            drSzklo:    szklo,
            drUlubiony: false,
            drNotatka:  notatka,
            drUwagi:    uwagi,
            drWWW:      "",
            drKal:      0,
            drMoc:      valToDrMoc(String(proc)),
            drBrakuje:  0,
            drAlkGlowny: [],
            drSklad:    [],
            drPrzepis:  [],
            drPolecany: false
        )
        modelContext.insert(drink)

        for (i, skl) in skladniki.enumerated() {
            let pozycja = DrSkladnik_M(
                relacjaDrink: drink,
                skladnik:     skl.skladnik,
                sklNo:        i + 1,
                sklIlosc:     skl.ilosc,
                sklMiara:     skl.miara,
                sklInfo:      skl.info,
                sklOpcja:     skl.opcja
            )
            modelContext.insert(pozycja)
        }

        for (i, krok) in kroki.enumerated() where !krok.opis.trimmingCharacters(in: .whitespaces).isEmpty {
            let przepis = DrPrzepis_M(
                relacjaDrink: drink,
                drinkID:      drinkID,
                przepNo:      i + 1,
                przepOpis:    krok.opis.trimmingCharacters(in: .whitespaces),
                przepOpcja:   krok.opcja
            )
            modelContext.insert(przepis)
        }

        drink.drBrakuje = 0
        try? modelContext.save()
    }
}

// MARK: - Wybór składnika

struct WyborSkladnika_V: View {
    let wszystkie: [Skl_M]
    let onWybor: (Skl_M) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var szukaj: String = ""

    var przefiltrowane: [Skl_M] {
        szukaj.isEmpty ? wszystkie : wszystkie.filter {
            $0.sklNazwa.localizedCaseInsensitiveContains(szukaj)
        }
    }

    var body: some View {
        NavigationStack {
            List(przefiltrowane) { skl in
                Button {
                    onWybor(skl)
                    dismiss()
                } label: {
                    HStack {
                        Text(skl.sklNazwa)
                            .foregroundStyle(.primary)
                        Spacer()
                        Text(skl.sklKat.opis)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .searchable(text: $szukaj, prompt: "Szukaj składnika")
            .navigationTitle("Wybierz składnik")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") { dismiss() }
                }
            }
        }
    }
}
