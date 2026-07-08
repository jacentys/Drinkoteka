import SwiftData
import Foundation

// MARK: - Synchronizacja drinków z Supabase
//
// Dane drinków są cache'owane lokalnie w SwiftData. Ta warstwa sprawdza,
// czy w bazie są drinki dostępne dla użytkownika, których nie ma lokalnie
// (nowe przepisy lub kategoria właśnie odblokowana), oraz po cichu usuwa
// drinki, do których użytkownik stracił dostęp (wylogowanie / cofnięcie
// uprawnień). RLS na tabeli `drinks` decyduje, które wiersze są widoczne.

private struct DrinkIDRow: Decodable {
    let id: String
}

// Zwraca zbiór ID drinków dostępnych dla bieżącej sesji (wg RLS).
func fetchAccessibleDrinkIDs() async throws -> Set<String> {
    let rows: [DrinkIDRow] = try await supabase
        .from("drinks")
        .select("id")
        .execute()
        .value
    return Set(rows.map { $0.id })
}

// Sprawdza aktualizacje:
// - po cichu usuwa lokalne drinki, do których nie ma już dostępu,
// - zwraca liczbę nowych drinków dostępnych do pobrania (nil = offline/błąd).
func sprawdzAktualizacjeDrinkow(modelContext: ModelContext) async -> Int? {
    guard let remoteIDs = try? await fetchAccessibleDrinkIDs() else { return nil }

    return await MainActor.run {
        let lokalne = (try? modelContext.fetch(FetchDescriptor<Dr_M>())) ?? []
        let lokalneIDs = Set(lokalne.map { $0.drinkID })

        // Usuń drinki bez dostępu (kaskada usuwa składniki i przepisy).
        // Wyjątek: własne drinki użytkownika (drZrodlo == "Własny") — ich nie ma
        // na serwerze, więc nie wolno ich kasować przy synchronizacji.
        let doUsuniecia = lokalne.filter { !remoteIDs.contains($0.drinkID) && $0.drZrodlo != "Własny" }
        for drink in doUsuniecia {
            modelContext.delete(drink)
        }
        if !doUsuniecia.isEmpty {
            try? modelContext.save()
        }

        // Nowe drinki = dostępne zdalnie, brak lokalnie
        return remoteIDs.subtracting(lokalneIDs).count
    }
}

// MARK: - Zapis edycji admina (kroki przepisu) na serwer
//
// Wypycha kroki przepisu drinka do Supabase. Językowo-świadomie:
// - PL → tabela bazowa drink_steps (wersja źródłowa),
// - inny język → drink_step_translations dla tego języka.
// Egzekucja roli admina jest po stronie serwera (RLS + is_admin()).
// Dotyczy tylko treści serwerowej (drZrodlo != "Własny").

private struct KrokPushDTO: Encodable {
    let drink_id: String
    let step_no: Int
    let description: String
    let optional: Bool
}
private struct KrokTrPushDTO: Encodable {
    let drink_id: String
    let step_no: Int
    let lang: String
    let description: String
}

@discardableResult
func pushKrokiAdmin(drink: Dr_M) async -> Bool {
    let lang = aktualnyJezykDanych()
    let (drinkID, kroki): (String, [(no: Int, opis: String, opcja: Bool)]) = await MainActor.run {
        (drink.drinkID,
         drink.drPrzepis
            .sorted { $0.przepNo < $1.przepNo }
            .map { ($0.przepNo, $0.przepOpis, $0.przepOpcja) })
    }
    let numery = "(\(kroki.map { String($0.no) }.joined(separator: ",")))"

    do {
        if lang == "pl" {
            let rows = kroki.map { KrokPushDTO(drink_id: drinkID, step_no: $0.no, description: $0.opis, optional: $0.opcja) }
            try await supabase.from("drink_steps").upsert(rows, onConflict: "drink_id,step_no").execute()
            // Usuń kroki, które już nie istnieją (usunięte / po zmianie numeracji)
            try await supabase.from("drink_steps").delete()
                .eq("drink_id", value: drinkID)
                .not("step_no", operator: .in, value: numery)
                .execute()
        } else {
            let rows = kroki.map { KrokTrPushDTO(drink_id: drinkID, step_no: $0.no, lang: lang, description: $0.opis) }
            try await supabase.from("drink_step_translations").upsert(rows, onConflict: "drink_id,step_no,lang").execute()
            try await supabase.from("drink_step_translations").delete()
                .eq("drink_id", value: drinkID)
                .eq("lang", value: lang)
                .not("step_no", operator: .in, value: numery)
                .execute()
        }
        return true
    } catch {
        dprint("[Admin] push kroków błąd: \(error)")
        return false
    }
}

// MARK: - Przeliczenie mocy i kaloryczności JEDNEGO drinka
//
// Wywoływane po edycji listy składników. Moc (drProc/drMoc) i kaloryczność
// (drKal) NIE są edytowalne ręcznie — liczone z listy składników, tak jak przy
// pierwszym ładowaniu z Supabase. Odpowiednik setAllDrinkProcenty/obliczKalorie,
// ale tylko dla jednego drinka (bez współdzielonego akumulatora między drinkami).
@MainActor
func przeliczMocIKalorie(_ drink: Dr_M) {
    var procenty: Double = 0
    var objetosc: Double = 0
    for drSkladnik in drink.drSklad where drSkladnik.sklMiara == .ml {
        objetosc += drSkladnik.sklIlosc
        procenty += Double(drSkladnik.skladnik.sklProc) * drSkladnik.sklIlosc
    }
    if objetosc > 0 {
        let objCalkowita = ((Double(drink.drSzklo.obj) - objetosc) * 0.25) + objetosc
        drink.drProc = objCalkowita > 0 ? Int(procenty / objCalkowita) : 0
    } else {
        drink.drProc = 0
    }
    drink.drMoc = strToDrMoc(drink.drProc)
    drink.setKalorie(kalorie: obliczKalorie(drink))
}

// MARK: - Zapis edycji admina (pola drinka) na serwer
//
// Wypycha podstawowe pola drinka (nazwa, kategoria, słodycz, szkło, uwagi,
// url, polecany, moc%, kalorie) do Supabase. Językowo-świadomie:
// - PL → tabela bazowa drinks,
// - inny język → drink_translations (name/remarks) dla tego języka.
// Kategoria/słodycz/szkło to wartości domenowe (nie tłumaczone tabelą
// translations — UI tłumaczy je przez String Catalog), więc idą tylko do PL.

private struct DrinkPolaPushDTO: Encodable {
    let name: String
    let category: String
    let sweetness: String
    let glass: String
    let remarks: String
    let url: String
    let recommended: Bool
    let alcohol_pct: Int
    let calories: Int
}
private struct DrinkTrPushDTO: Encodable {
    let drink_id: String
    let lang: String
    let name: String
    let remarks: String
}

@discardableResult
func pushPolaAdmin(drink: Dr_M) async -> Bool {
    let lang = aktualnyJezykDanych()
    let (drinkID, dto): (String, DrinkPolaPushDTO) = await MainActor.run {
        (drink.drinkID, DrinkPolaPushDTO(
            name: drink.drNazwa, category: drink.drKat.rawValue, sweetness: drink.drSlodycz.rawValue,
            glass: drink.drSzklo.rawValue, remarks: drink.drUwagi, url: drink.drWWW,
            recommended: drink.drPolecany, alcohol_pct: drink.drProc, calories: drink.drKal))
    }
    do {
        if lang == "pl" {
            try await supabase.from("drinks").update(dto).eq("id", value: drinkID).execute()
        } else {
            let tr = DrinkTrPushDTO(drink_id: drinkID, lang: lang, name: dto.name, remarks: dto.remarks)
            try await supabase.from("drink_translations").upsert(tr, onConflict: "drink_id,lang").execute()
            // Moc/kalorie/kategoria/słodycz/szkło/polecany/url są językowo-niezależne — zawsze do PL
            try await supabase.from("drinks").update(
                DrinkPolaJezykNiezalezneDTO(category: dto.category, sweetness: dto.sweetness, glass: dto.glass,
                                            url: dto.url, recommended: dto.recommended,
                                            alcohol_pct: dto.alcohol_pct, calories: dto.calories)
            ).eq("id", value: drinkID).execute()
        }
        return true
    } catch {
        dprint("[Admin] push pól drinka błąd: \(error)")
        return false
    }
}
private struct DrinkPolaJezykNiezalezneDTO: Encodable {
    let category: String
    let sweetness: String
    let glass: String
    let url: String
    let recommended: Bool
    let alcohol_pct: Int
    let calories: Int
}

// MARK: - Zapis edycji admina (składniki drinka) na serwer
//
// Wypycha listę składników drinka do Supabase (upsert po drink_id+sort_order,
// usunięcie pozycji spoza aktualnej listy). Info (opis użycia) jest tłumaczone
// w drink_ingredient_translations; ilość/miara/opcjonalność/kolejność są
// językowo-niezależne i zawsze idą do drink_ingredients.
// Składniki własne użytkownika (sklWlasny, nieobecne na serwerze) są pomijane —
// nie da się ich wypchnąć (naruszyłoby FK ingredient_id -> ingredients).

private struct SkladnikPushDTO: Encodable {
    let drink_id: String
    let ingredient_id: String
    let amount: Double
    let unit: String
    let info: String
    let optional: Bool
    let sort_order: Int
}
private struct SkladnikTrPushDTO: Encodable {
    let drink_id: String
    let ingredient_id: String
    let lang: String
    let info: String
}

@discardableResult
func pushSkladnikiAdmin(drink: Dr_M) async -> Bool {
    let lang = aktualnyJezykDanych()
    let (drinkID, pozycje, pominiete): (String, [(sklID: String, ilosc: Double, miara: String, info: String, opcja: Bool, no: Int)], Int) = await MainActor.run {
        let posortowane = drink.drSklad.sorted { $0.sklNo < $1.sklNo }
        let serwerowe = posortowane.filter { !$0.skladnik.sklWlasny }
        return (drink.drinkID,
                serwerowe.map { ($0.skladnik.sklID, $0.sklIlosc, $0.sklMiara.rawValue, $0.sklInfo, $0.sklOpcja, $0.sklNo) },
                posortowane.count - serwerowe.count)
    }
    if pominiete > 0 {
        dprint("[Admin] pominięto \(pominiete) własnych składników przy push (brak na serwerze)")
    }
    guard !pozycje.isEmpty else { return true }
    let numeryKolejnosci = "(\(pozycje.map { String($0.no) }.joined(separator: ",")))"

    do {
        let rowsPL = pozycje.map {
            SkladnikPushDTO(drink_id: drinkID, ingredient_id: $0.sklID, amount: $0.ilosc,
                            unit: $0.miara, info: lang == "pl" ? $0.info : "", optional: $0.opcja, sort_order: $0.no)
        }
        try await supabase.from("drink_ingredients").upsert(rowsPL, onConflict: "drink_id,sort_order").execute()
        try await supabase.from("drink_ingredients").delete()
            .eq("drink_id", value: drinkID)
            .not("sort_order", operator: .in, value: numeryKolejnosci)
            .execute()

        if lang != "pl" {
            let rowsTr = pozycje.map {
                SkladnikTrPushDTO(drink_id: drinkID, ingredient_id: $0.sklID, lang: lang, info: $0.info)
            }
            try await supabase.from("drink_ingredient_translations").upsert(rowsTr, onConflict: "drink_id,ingredient_id,lang").execute()
        }
        return true
    } catch {
        dprint("[Admin] push składników błąd: \(error)")
        return false
    }
}

// MARK: - Dodanie/usunięcie CAŁEGO drinka do/z katalogu (admin)
//
// Admin może dodać nowo utworzony drink jako pozycję katalogu (widoczną dla
// wszystkich, drZrodlo != "Własny") albo usunąć drink z serwera. Kaskada
// (drink_ingredients, drink_steps, tłumaczenia) obsłużona przez FK ON DELETE CASCADE.

private struct DrinkInsertDTO: Encodable {
    let id: String
    let name: String
    let category: String
    let source: String
    let alcohol_pct: Int
    let sweetness: String
    let glass: String
    let remarks: String
    let url: String
    let calories: Int
    let recommended: Bool
}

@discardableResult
func pushNowyDrinkDoKatalogu(drink: Dr_M) async -> Bool {
    let dto: DrinkInsertDTO = await MainActor.run {
        DrinkInsertDTO(
            id: drink.drinkID, name: drink.drNazwa, category: drink.drKat.rawValue,
            source: drink.drZrodlo, alcohol_pct: drink.drProc, sweetness: drink.drSlodycz.rawValue,
            glass: drink.drSzklo.rawValue, remarks: drink.drUwagi, url: drink.drWWW,
            calories: drink.drKal, recommended: drink.drPolecany)
    }
    do {
        try await supabase.from("drinks").insert(dto).execute()
        async let skl = pushSkladnikiAdmin(drink: drink)
        async let kroki = pushKrokiAdmin(drink: drink)
        _ = await (skl, kroki)
        return true
    } catch {
        dprint("[Admin] dodanie drinka do katalogu błąd: \(error)")
        return false
    }
}

@discardableResult
func usunDrinkZServera(drinkId: String) async -> Bool {
    do {
        try await supabase.from("drinks").delete().eq("id", value: drinkId).execute()
        return true
    } catch {
        dprint("[Admin] usunięcie drinka z serwera błąd: \(error)")
        return false
    }
}
