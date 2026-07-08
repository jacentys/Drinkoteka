// Warianty listy drinków posortowane wg różnych kryteriów (słodycz, moc, kalorie, skład).
import SwiftUI
import SwiftData

// Wspólny mixin filtrów — każdy widok sortowania deklaruje te same @AppStorage
// i wywołuje filtrujDrinki(drinki:) żeby dostać przefiltrowaną listę.

private func filtrujDrinki(
    drinki: [Dr_M],
    szukaj: String,
    filtrSlodkoscNieSlodki: Bool,
    filtrSlodkoscLekkoSlodki: Bool,
    filtrSlodkoscSlodki: Bool,
    filtrSlodkoscBardzoSlodki: Bool,
    filtrAlkGlownyRum: Bool,
    filtrAlkGlownyWhiskey: Bool,
    filtrAlkGlownyTequila: Bool,
    filtrAlkGlownyBrandy: Bool,
    filtrAlkGlownyGin: Bool,
    filtrAlkGlownyVodka: Bool,
    filtrAlkGlownyChampagne: Bool,
    filtrAlkGlownyInny: Bool,
    filtrMocBezalk: Bool,
    filtrMocDelik: Bool,
    filtrMocSredni: Bool,
    filtrMocMocny: Bool,
    tylkoUlubione: Bool,
    tylkoDostepne: Bool
) -> [Dr_M] {
    let baza = szukaj.isEmpty ? drinki : drinki.filter {
        $0.drNazwa.localizedCaseInsensitiveContains(szukaj)
    }
    return baza.filter { drink in
        let filtrSlodkosci =
            (filtrSlodkoscNieSlodki    && drink.drSlodycz == .nieSlodki) ||
            (filtrSlodkoscLekkoSlodki  && drink.drSlodycz == .lekkoSlodki) ||
            (filtrSlodkoscSlodki       && drink.drSlodycz == .slodki) ||
            (filtrSlodkoscBardzoSlodki && drink.drSlodycz == .bardzoSlodki) ||
            (drink.drSlodycz == .brakDanych)

        let filtrAlkGlownego =
            (filtrAlkGlownyRum        && drink.drAlkGlowny.contains { $0 == .rum }) ||
            (filtrAlkGlownyWhiskey    && drink.drAlkGlowny.contains { $0 == .whiskey }) ||
            (filtrAlkGlownyTequila    && drink.drAlkGlowny.contains { $0 == .tequila }) ||
            (filtrAlkGlownyBrandy     && drink.drAlkGlowny.contains { $0 == .brandy }) ||
            (filtrAlkGlownyGin        && drink.drAlkGlowny.contains { $0 == .gin }) ||
            (filtrAlkGlownyVodka      && drink.drAlkGlowny.contains { $0 == .vodka }) ||
            (filtrAlkGlownyChampagne  && drink.drAlkGlowny.contains { $0 == .champagne }) ||
            (filtrAlkGlownyInny       && drink.drAlkGlowny.contains { $0 == .inny })

        let filtrMocy =
            (filtrMocBezalk && drink.drMoc == .bezalk) ||
            (filtrMocDelik  && drink.drMoc == .delik)  ||
            (filtrMocSredni && drink.drMoc == .sredni) ||
            (filtrMocMocny  && drink.drMoc == .mocny)  ||
            drink.drMoc == .brakDanych

        let filtrPreferencji =
            (!tylkoUlubione || drink.drUlubiony) &&
            (!tylkoDostepne || drink.drBrakuje == 0)

        return filtrSlodkosci && filtrMocy && filtrAlkGlownego && filtrPreferencji
    }
}

// MARK: - Wiersz z obsługą blokady (wspólny dla wszystkich widoków sortowania)

struct DrinkListaWiersz_V: View {
    let drink: Dr_M
    let mozeOtworzyc: Bool

    var body: some View {
        // IBA darmowe; kategorie specjalne wg kodu; reszta nie-IBA wg Premium.
        // Zablokowane (nie-IBA bez Premium) są widoczne, ale prowadzą do ekranu Premium.
        if mozeOtworzyc {
            NavigationLink(destination: Drink_V(drink: drink)) {
                DrinkListaRow_V(drink: drink)
            }
            .listRowBackground(Color.white.opacity(0.4))
            .buttonStyle(.plain)
        } else {
            DrinkZablokowany_V(drink: drink)
                .listRowBackground(Color.white.opacity(0.2))
        }
    }
}

// MARK: - Nagłówek sekcji sortowania

struct SortSekcjaHeader_V: View {
    let tytul: LocalizedStringKey
    let ilosc: Int

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(tytul)
                .font(.title2)
                .textCase(.uppercase)
            Text(" - \(ilosc) ")
                .font(.title2)
            Text("przep.")
                .font(.footnote)
            Spacer()
        }
        .fontWeight(.light)
        .foregroundColor(Color.primary)
        .listRowBackground(Color.white.opacity(0.7))
        .padding(.horizontal, 12)
    }
}

// MARK: - SORT SŁODYCZ

struct SortSlodyczView: View {
    @Query(sort: \Dr_M.drNazwa) private var drinki: [Dr_M]
    @StateObject private var auth = AuthService_VM.shared

    @AppStorage("sortowRosn")              var sortowRosn: Bool = true
    @AppStorage("filtrSlodkoscNieSlodki")  var filtrSlodkoscNieSlodki: Bool = true
    @AppStorage("filtrSlodkoscLekkoSlodki") var filtrSlodkoscLekkoSlodki: Bool = true
    @AppStorage("filtrSlodkoscSlodki")     var filtrSlodkoscSlodki: Bool = true
    @AppStorage("filtrSlodkoscBardzoSlodki") var filtrSlodkoscBardzoSlodki: Bool = true
    @AppStorage("filtrAlkGlownyRum")       var filtrAlkGlownyRum: Bool = true
    @AppStorage("filtrAlkGlownyWhiskey")   var filtrAlkGlownyWhiskey: Bool = true
    @AppStorage("filtrAlkGlownyTequila")   var filtrAlkGlownyTequila: Bool = true
    @AppStorage("filtrAlkGlownyBrandy")    var filtrAlkGlownyBrandy: Bool = true
    @AppStorage("filtrAlkGlownyGin")       var filtrAlkGlownyGin: Bool = true
    @AppStorage("filtrAlkGlownyVodka")     var filtrAlkGlownyVodka: Bool = true
    @AppStorage("filtrAlkGlownyChampagne") var filtrAlkGlownyChampagne: Bool = true
    @AppStorage("filtrAlkGlownyInny")      var filtrAlkGlownyInny: Bool = true
    @AppStorage("filtrMocBezalk")          var filtrMocBezalk: Bool = true
    @AppStorage("filtrMocDelik")           var filtrMocDelik: Bool = true
    @AppStorage("filtrMocSredni")          var filtrMocSredni: Bool = true
    @AppStorage("filtrMocMocny")           var filtrMocMocny: Bool = true
    @AppStorage("tylkoUlubione")           var tylkoUlubione: Bool = false
    @AppStorage("tylkoDostepne")           var tylkoDostepne: Bool = false

    var przefiltrowane: [Dr_M] {
        filtrujDrinki(drinki: drinki, szukaj: "",
            filtrSlodkoscNieSlodki: filtrSlodkoscNieSlodki,
            filtrSlodkoscLekkoSlodki: filtrSlodkoscLekkoSlodki,
            filtrSlodkoscSlodki: filtrSlodkoscSlodki,
            filtrSlodkoscBardzoSlodki: filtrSlodkoscBardzoSlodki,
            filtrAlkGlownyRum: filtrAlkGlownyRum,
            filtrAlkGlownyWhiskey: filtrAlkGlownyWhiskey,
            filtrAlkGlownyTequila: filtrAlkGlownyTequila,
            filtrAlkGlownyBrandy: filtrAlkGlownyBrandy,
            filtrAlkGlownyGin: filtrAlkGlownyGin,
            filtrAlkGlownyVodka: filtrAlkGlownyVodka,
            filtrAlkGlownyChampagne: filtrAlkGlownyChampagne,
            filtrAlkGlownyInny: filtrAlkGlownyInny,
            filtrMocBezalk: filtrMocBezalk,
            filtrMocDelik: filtrMocDelik,
            filtrMocSredni: filtrMocSredni,
            filtrMocMocny: filtrMocMocny,
            tylkoUlubione: tylkoUlubione,
            tylkoDostepne: tylkoDostepne)
    }

    var enumSorted: [drSlodyczEnum] {
        drSlodyczEnum.allCases.sorted {
            sortowRosn ? $0.sort < $1.sort : $0.sort > $1.sort
        }
    }

    var body: some View {
        ForEach(enumSorted, id: \.sort) { slodycz in
            let sekcja = przefiltrowane.filter { $0.drSlodycz == slodycz }
            if !sekcja.isEmpty {
                Section(header: SortSekcjaHeader_V(tytul: LocalizedStringKey(slodycz.opis), ilosc: sekcja.count)) {
                    ForEach(sekcja) { drink in
                        DrinkListaWiersz_V(drink: drink, mozeOtworzyc: auth.mozeOtworzyc(drink))
                    }
                }
            }
        }
    }
}

// MARK: - SORT MOC

struct SortMocView: View {
    @Query(sort: \Dr_M.drProc) private var drinki: [Dr_M]
    @StateObject private var auth = AuthService_VM.shared

    @AppStorage("sortowRosn")              var sortowRosn: Bool = true
    @AppStorage("filtrSlodkoscNieSlodki")  var filtrSlodkoscNieSlodki: Bool = true
    @AppStorage("filtrSlodkoscLekkoSlodki") var filtrSlodkoscLekkoSlodki: Bool = true
    @AppStorage("filtrSlodkoscSlodki")     var filtrSlodkoscSlodki: Bool = true
    @AppStorage("filtrSlodkoscBardzoSlodki") var filtrSlodkoscBardzoSlodki: Bool = true
    @AppStorage("filtrAlkGlownyRum")       var filtrAlkGlownyRum: Bool = true
    @AppStorage("filtrAlkGlownyWhiskey")   var filtrAlkGlownyWhiskey: Bool = true
    @AppStorage("filtrAlkGlownyTequila")   var filtrAlkGlownyTequila: Bool = true
    @AppStorage("filtrAlkGlownyBrandy")    var filtrAlkGlownyBrandy: Bool = true
    @AppStorage("filtrAlkGlownyGin")       var filtrAlkGlownyGin: Bool = true
    @AppStorage("filtrAlkGlownyVodka")     var filtrAlkGlownyVodka: Bool = true
    @AppStorage("filtrAlkGlownyChampagne") var filtrAlkGlownyChampagne: Bool = true
    @AppStorage("filtrAlkGlownyInny")      var filtrAlkGlownyInny: Bool = true
    @AppStorage("filtrMocBezalk")          var filtrMocBezalk: Bool = true
    @AppStorage("filtrMocDelik")           var filtrMocDelik: Bool = true
    @AppStorage("filtrMocSredni")          var filtrMocSredni: Bool = true
    @AppStorage("filtrMocMocny")           var filtrMocMocny: Bool = true
    @AppStorage("tylkoUlubione")           var tylkoUlubione: Bool = false
    @AppStorage("tylkoDostepne")           var tylkoDostepne: Bool = false

    var przefiltrowane: [Dr_M] {
        filtrujDrinki(drinki: drinki, szukaj: "",
            filtrSlodkoscNieSlodki: filtrSlodkoscNieSlodki,
            filtrSlodkoscLekkoSlodki: filtrSlodkoscLekkoSlodki,
            filtrSlodkoscSlodki: filtrSlodkoscSlodki,
            filtrSlodkoscBardzoSlodki: filtrSlodkoscBardzoSlodki,
            filtrAlkGlownyRum: filtrAlkGlownyRum,
            filtrAlkGlownyWhiskey: filtrAlkGlownyWhiskey,
            filtrAlkGlownyTequila: filtrAlkGlownyTequila,
            filtrAlkGlownyBrandy: filtrAlkGlownyBrandy,
            filtrAlkGlownyGin: filtrAlkGlownyGin,
            filtrAlkGlownyVodka: filtrAlkGlownyVodka,
            filtrAlkGlownyChampagne: filtrAlkGlownyChampagne,
            filtrAlkGlownyInny: filtrAlkGlownyInny,
            filtrMocBezalk: filtrMocBezalk,
            filtrMocDelik: filtrMocDelik,
            filtrMocSredni: filtrMocSredni,
            filtrMocMocny: filtrMocMocny,
            tylkoUlubione: tylkoUlubione,
            tylkoDostepne: tylkoDostepne)
    }

    var enumSorted: [drMocEnum] {
        drMocEnum.allCases.sorted {
            sortowRosn ? $0.sort < $1.sort : $0.sort > $1.sort
        }
    }

    var body: some View {
        ForEach(enumSorted, id: \.rawValue) { moc in
            let sekcja = przefiltrowane
                .filter { $0.drMoc == moc }
                .sorted { sortowRosn ? $0.drProc < $1.drProc : $0.drProc > $1.drProc }
            if !sekcja.isEmpty {
                Section(header: SortSekcjaHeader_V(tytul: LocalizedStringKey(moc.opisLong), ilosc: sekcja.count)) {
                    ForEach(sekcja) { drink in
                        DrinkListaWiersz_V(drink: drink, mozeOtworzyc: auth.mozeOtworzyc(drink))
                    }
                }
            }
        }
    }
}

// MARK: - SORT KALORIE

struct SortKcalView: View {
    @Query(sort: \Dr_M.drKal) private var drinki: [Dr_M]
    @StateObject private var auth = AuthService_VM.shared

    @AppStorage("sortowRosn")              var sortowRosn: Bool = true
    @AppStorage("filtrSlodkoscNieSlodki")  var filtrSlodkoscNieSlodki: Bool = true
    @AppStorage("filtrSlodkoscLekkoSlodki") var filtrSlodkoscLekkoSlodki: Bool = true
    @AppStorage("filtrSlodkoscSlodki")     var filtrSlodkoscSlodki: Bool = true
    @AppStorage("filtrSlodkoscBardzoSlodki") var filtrSlodkoscBardzoSlodki: Bool = true
    @AppStorage("filtrAlkGlownyRum")       var filtrAlkGlownyRum: Bool = true
    @AppStorage("filtrAlkGlownyWhiskey")   var filtrAlkGlownyWhiskey: Bool = true
    @AppStorage("filtrAlkGlownyTequila")   var filtrAlkGlownyTequila: Bool = true
    @AppStorage("filtrAlkGlownyBrandy")    var filtrAlkGlownyBrandy: Bool = true
    @AppStorage("filtrAlkGlownyGin")       var filtrAlkGlownyGin: Bool = true
    @AppStorage("filtrAlkGlownyVodka")     var filtrAlkGlownyVodka: Bool = true
    @AppStorage("filtrAlkGlownyChampagne") var filtrAlkGlownyChampagne: Bool = true
    @AppStorage("filtrAlkGlownyInny")      var filtrAlkGlownyInny: Bool = true
    @AppStorage("filtrMocBezalk")          var filtrMocBezalk: Bool = true
    @AppStorage("filtrMocDelik")           var filtrMocDelik: Bool = true
    @AppStorage("filtrMocSredni")          var filtrMocSredni: Bool = true
    @AppStorage("filtrMocMocny")           var filtrMocMocny: Bool = true
    @AppStorage("tylkoUlubione")           var tylkoUlubione: Bool = false
    @AppStorage("tylkoDostepne")           var tylkoDostepne: Bool = false

    var posortowane: [Dr_M] {
        let lista = filtrujDrinki(drinki: drinki, szukaj: "",
            filtrSlodkoscNieSlodki: filtrSlodkoscNieSlodki,
            filtrSlodkoscLekkoSlodki: filtrSlodkoscLekkoSlodki,
            filtrSlodkoscSlodki: filtrSlodkoscSlodki,
            filtrSlodkoscBardzoSlodki: filtrSlodkoscBardzoSlodki,
            filtrAlkGlownyRum: filtrAlkGlownyRum,
            filtrAlkGlownyWhiskey: filtrAlkGlownyWhiskey,
            filtrAlkGlownyTequila: filtrAlkGlownyTequila,
            filtrAlkGlownyBrandy: filtrAlkGlownyBrandy,
            filtrAlkGlownyGin: filtrAlkGlownyGin,
            filtrAlkGlownyVodka: filtrAlkGlownyVodka,
            filtrAlkGlownyChampagne: filtrAlkGlownyChampagne,
            filtrAlkGlownyInny: filtrAlkGlownyInny,
            filtrMocBezalk: filtrMocBezalk,
            filtrMocDelik: filtrMocDelik,
            filtrMocSredni: filtrMocSredni,
            filtrMocMocny: filtrMocMocny,
            tylkoUlubione: tylkoUlubione,
            tylkoDostepne: tylkoDostepne)
        return sortowRosn ? lista : lista.reversed()
    }

    var body: some View {
        ForEach(posortowane) { drink in
            DrinkListaWiersz_V(drink: drink, mozeOtworzyc: auth.mozeOtworzyc(drink))
        }
    }
}

// MARK: - SORT SKŁAD (wg brakujących składników)

struct SortSkladView: View {
    @Query(sort: \Dr_M.drNazwa) private var drinki: [Dr_M]
    @StateObject private var auth = AuthService_VM.shared

    @AppStorage("sortowRosn")              var sortowRosn: Bool = true
    @AppStorage("filtrSlodkoscNieSlodki")  var filtrSlodkoscNieSlodki: Bool = true
    @AppStorage("filtrSlodkoscLekkoSlodki") var filtrSlodkoscLekkoSlodki: Bool = true
    @AppStorage("filtrSlodkoscSlodki")     var filtrSlodkoscSlodki: Bool = true
    @AppStorage("filtrSlodkoscBardzoSlodki") var filtrSlodkoscBardzoSlodki: Bool = true
    @AppStorage("filtrAlkGlownyRum")       var filtrAlkGlownyRum: Bool = true
    @AppStorage("filtrAlkGlownyWhiskey")   var filtrAlkGlownyWhiskey: Bool = true
    @AppStorage("filtrAlkGlownyTequila")   var filtrAlkGlownyTequila: Bool = true
    @AppStorage("filtrAlkGlownyBrandy")    var filtrAlkGlownyBrandy: Bool = true
    @AppStorage("filtrAlkGlownyGin")       var filtrAlkGlownyGin: Bool = true
    @AppStorage("filtrAlkGlownyVodka")     var filtrAlkGlownyVodka: Bool = true
    @AppStorage("filtrAlkGlownyChampagne") var filtrAlkGlownyChampagne: Bool = true
    @AppStorage("filtrAlkGlownyInny")      var filtrAlkGlownyInny: Bool = true
    @AppStorage("filtrMocBezalk")          var filtrMocBezalk: Bool = true
    @AppStorage("filtrMocDelik")           var filtrMocDelik: Bool = true
    @AppStorage("filtrMocSredni")          var filtrMocSredni: Bool = true
    @AppStorage("filtrMocMocny")           var filtrMocMocny: Bool = true
    @AppStorage("tylkoUlubione")           var tylkoUlubione: Bool = false
    @AppStorage("tylkoDostepne")           var tylkoDostepne: Bool = false

    var przefiltrowane: [Dr_M] {
        filtrujDrinki(drinki: drinki, szukaj: "",
            filtrSlodkoscNieSlodki: filtrSlodkoscNieSlodki,
            filtrSlodkoscLekkoSlodki: filtrSlodkoscLekkoSlodki,
            filtrSlodkoscSlodki: filtrSlodkoscSlodki,
            filtrSlodkoscBardzoSlodki: filtrSlodkoscBardzoSlodki,
            filtrAlkGlownyRum: filtrAlkGlownyRum,
            filtrAlkGlownyWhiskey: filtrAlkGlownyWhiskey,
            filtrAlkGlownyTequila: filtrAlkGlownyTequila,
            filtrAlkGlownyBrandy: filtrAlkGlownyBrandy,
            filtrAlkGlownyGin: filtrAlkGlownyGin,
            filtrAlkGlownyVodka: filtrAlkGlownyVodka,
            filtrAlkGlownyChampagne: filtrAlkGlownyChampagne,
            filtrAlkGlownyInny: filtrAlkGlownyInny,
            filtrMocBezalk: filtrMocBezalk,
            filtrMocDelik: filtrMocDelik,
            filtrMocSredni: filtrMocSredni,
            filtrMocMocny: filtrMocMocny,
            tylkoUlubione: tylkoUlubione,
            tylkoDostepne: tylkoDostepne)
    }

    var zakres: [Int] {
        guard !przefiltrowane.isEmpty else { return [] }
        let min = przefiltrowane.map { $0.drBrakuje }.min() ?? 0
        let max = przefiltrowane.map { $0.drBrakuje }.max() ?? 0
        let indeksy = Array(min...max)
        return sortowRosn ? indeksy : indeksy.reversed()
    }

    var body: some View {
        ForEach(zakres, id: \.self) { idx in
            let sekcja = przefiltrowane
                .filter { $0.drBrakuje == idx }
                .sorted { $0.drNazwa < $1.drNazwa }
            if !sekcja.isEmpty {
                let tytul: LocalizedStringKey = idx == 0
                    ? "Masz wszystkie skł."
                    : "Brak \(idx) skł."
                Section(header: SortSekcjaHeader_V(tytul: tytul, ilosc: sekcja.count)) {
                    ForEach(sekcja) { drink in
                        DrinkListaWiersz_V(drink: drink, mozeOtworzyc: auth.mozeOtworzyc(drink))
                    }
                }
            }
        }
    }
}
