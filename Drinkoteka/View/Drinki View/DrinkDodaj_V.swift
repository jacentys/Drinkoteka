import SwiftUI
import SwiftData
import PhotosUI

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
    @StateObject private var auth = AuthService_VM.shared
    @Query(sort: \Skl_M.sklNazwa) private var wszystkieSkladniki: [Skl_M]

    // Admin: dodaj do wspólnego katalogu (widoczne dla wszystkich) zamiast lokalnie
    @State private var doKatalogu: Bool = false
    @State private var zapisuje: Bool = false

    // Podstawowe
    @State private var nazwa: String = ""
    @State private var kategoria: drKatEnum = .koktail
    @State private var slodycz: drSlodyczEnum = .brakDanych
    @State private var szklo: szkloEnum = .koktailowy
    @State private var procAlk: String = "0"
    @State private var notatka: String = ""
    @State private var uwagi: String = ""

    // Zdjęcie
    @State private var wybranePhotoItem: PhotosPickerItem? = nil
    @State private var wybraneZdjecie: UIImage? = nil

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

                // MARK: Zdjęcie
                Section(header: Text("Zdjęcie")) {
                    HStack {
                        Group {
                            if let img = wybraneZdjecie {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Image(systemName: "photo")
                                    .font(.title)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                        PhotosPicker(selection: $wybranePhotoItem, matching: .images) {
                            Label(wybraneZdjecie == nil ? "Dodaj zdjęcie" : "Zmień zdjęcie", systemImage: "photo.on.rectangle")
                        }
                        Spacer()
                        if wybraneZdjecie != nil {
                            Button(role: .destructive) {
                                wybraneZdjecie = nil
                                wybranePhotoItem = nil
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
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

                // MARK: Admin — publikacja w katalogu
                if auth.isAdmin {
                    Section(
                        header: Text("Administrator"),
                        footer: Text("Drink zostanie zapisany na serwerze i będzie widoczny dla wszystkich użytkowników, zamiast pozostać tylko na tym urządzeniu.")
                    ) {
                        Toggle("Dodaj do wspólnego katalogu", isOn: $doKatalogu)
                    }
                }
            }
            .navigationTitle("Nowy drink")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if zapisuje {
                        ProgressView()
                    } else {
                        Button("Dodaj") {
                            let drink = dodajDrink()
                            if auth.isAdmin && doKatalogu {
                                zapisuje = true
                                Task {
                                    await pushNowyDrinkDoKatalogu(drink: drink)
                                    await MainActor.run { dismiss() }
                                }
                            } else {
                                dismiss()
                            }
                        }
                        .disabled(nazwa.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $pokazWyborSkladnika) {
                // Do katalogu: tylko składniki obecne na serwerze (FK ingredient_id)
                let doKatalog = auth.isAdmin && doKatalogu
                let dostepne = doKatalog ? wszystkieSkladniki.filter { !$0.sklWlasny } : wszystkieSkladniki
                WyborSkladnika_V(wszystkie: dostepne, dozwolNowy: !doKatalog) { wybrany in
                    skladniki.append(NowySkladnik(skladnik: wybrany))
                }
            }
            .onChange(of: wybranePhotoItem) { _, nowy in
                Task {
                    if let data = try? await nowy?.loadTransferable(type: Data.self),
                       let img = UIImage(data: data) {
                        wybraneZdjecie = img
                    }
                }
            }
        }
    }

    @discardableResult
    private func dodajDrink() -> Dr_M {
        let proc = Int(procAlk) ?? 0
        let drinkID = UUID().uuidString
        let doKatalog = auth.isAdmin && doKatalogu
        // Własne zdjęcie (zapisane do Documents) albo domyślna grafika szkła
        // (drinki katalogowe nie synchronizują zdjęcia — fallback do szkła u innych)
        let foto = wybraneZdjecie.flatMap { DrinkPhotoStore.save($0) } ?? szklo.foto
        let drink = Dr_M(
            drinkID:    drinkID,
            drNazwa:    nazwa.trimmingCharacters(in: .whitespaces),
            drKat:      kategoria,
            drZrodlo:   doKatalog ? "Katalog" : "Własny",
            drKolor:    "",
            drFoto:     foto,
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
            drPrzepis:  []
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
        przeliczMocIKalorie(drink)
        try? modelContext.save()
        return drink
    }
}

// MARK: - Wybór składnika

struct WyborSkladnika_V: View {
    let wszystkie: [Skl_M]
    let onWybor: (Skl_M) -> Void
    // false przy edycji drinka katalogowego — nowy lokalny składnik naruszyłby FK na serwerze
    var dozwolNowy: Bool = true

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var szukaj: String = ""
    @State private var pokazNowy: Bool = false

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
                if dozwolNowy {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            pokazNowy = true
                        } label: {
                            Label("Nowy składnik", systemImage: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $pokazNowy) {
                NowySkladnik_V(istniejace: wszystkie) { nowy in
                    // Zapisz nowy składnik do bazy lokalnej i wybierz go do drinka
                    modelContext.insert(nowy)
                    try? modelContext.save()
                    onWybor(nowy)
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Tworzenie nowego składnika

struct NowySkladnik_V: View {
    let istniejace: [Skl_M]
    let onUtworz: (Skl_M) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var nazwa: String = ""
    @State private var kategoria: sklKatEnum = .alkohol
    @State private var proc: String = "0"
    @State private var kal: String = "0"
    @State private var miara: miaraEnum = .ml
    @State private var opis: String = ""
    @State private var blad: String? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Nowy składnik")) {
                    TextField("Nazwa", text: $nazwa)

                    Picker("Kategoria", selection: $kategoria) {
                        ForEach(sklKatEnum.allCases, id: \.self) {
                            Text($0.opis).tag($0)
                        }
                    }

                    HStack {
                        Text("Alkohol %")
                        Spacer()
                        TextField("0", text: $proc)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                    }

                    HStack {
                        Text("Kalorie / 100")
                        Spacer()
                        TextField("0", text: $kal)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                    }

                    Picker("Domyślna miara", selection: $miara) {
                        ForEach(miaraEnum.allCases, id: \.self) {
                            Text($0.opis).tag($0)
                        }
                    }
                }

                Section(header: Text("Opis (opcjonalnie)")) {
                    TextField("Opis składnika", text: $opis, axis: .vertical)
                        .lineLimit(2...5)
                }

                if let b = blad {
                    Text(b).foregroundStyle(.red).font(.caption)
                }
            }
            .navigationTitle("Nowy składnik")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Dodaj") { utworz() }
                        .disabled(nazwa.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func utworz() {
        let n = nazwa.trimmingCharacters(in: .whitespaces)
        // Nazwa składnika jest unikalna (@Attribute(.unique)) — blokujemy duplikaty
        if istniejace.contains(where: { $0.sklNazwa.localizedCaseInsensitiveCompare(n) == .orderedSame }) {
            blad = "Składnik o tej nazwie już istnieje."
            return
        }
        let skl = Skl_M(
            sklID:    UUID().uuidString,
            sklNazwa: n,
            sklKat:   kategoria,
            sklProc:  Int(proc) ?? 0,
            sklKolor: "",
            sklFoto:  "",
            sklStan:  .brak,
            sklOpis:  opis.trimmingCharacters(in: .whitespaces),
            sklKal:   Int(kal) ?? 0,
            sklMiara: miara,
            sklWWW:   ""
        )
        skl.sklWlasny = true
        onUtworz(skl)
        dismiss()
    }
}
