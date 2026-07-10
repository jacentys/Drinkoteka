import SwiftData
import Foundation

// MARK: - Język danych

// Aktualnie wybrany język treści (z ustawień). Baza przechowuje PL jako
// fallback; dla innych języków pobierane są tłumaczenia z tabel *_translations.
func aktualnyJezykDanych() -> String {
    UserDefaults.standard.string(forKey: "jezykAplikacji") ?? "pl"
}

// MARK: - Główna funkcja ładowania

@discardableResult
func loadFromSupabase(modelContext: ModelContext) async -> Bool {
    let lang = aktualnyJezykDanych()
    do {
        async let ingredientsDTOs   = fetchIngredients()
        async let substitutesDTOs   = fetchSubstitutes()
        async let drinksDTOs        = fetchDrinks()
        async let drinkIngredDTOs   = fetchDrinkIngredients()
        async let drinkStepsDTOs    = fetchDrinkSteps()
        async let drinkSpiritsDTOs  = fetchDrinkSpirits()

        let (ingredients, substitutes, drinks, drinkIngredients, drinkSteps, drinkSpirits) = try await (
            ingredientsDTOs, substitutesDTOs, drinksDTOs,
            drinkIngredDTOs, drinkStepsDTOs, drinkSpiritsDTOs
        )

        // Tłumaczenia pobieramy tylko gdy język != PL (PL jest w tabelach bazowych)
        let trans = lang == "pl" ? Tlumaczenia() : (try? await fetchTlumaczenia(lang: lang)) ?? Tlumaczenia()

        // Wstawiamy na głównym wątku (ModelContext nie jest thread-safe).
        // Loader jest idempotentny — pomija rekordy już obecne lokalnie,
        // dzięki czemu ponowne wywołanie dodaje tylko nowe drinki i nie
        // kasuje stanu barku (sklStan) ani ulubionych.
        await MainActor.run {
            insertIngredients(ingredients, trans: trans, context: modelContext)
            let noweDrinkIDs = insertDrinks(drinks, trans: trans, context: modelContext)
            insertDrinkIngredients(drinkIngredients, substitutes: substitutes, trans: trans, noweDrinkIDs: noweDrinkIDs, context: modelContext)
            insertDrinkSteps(drinkSteps, trans: trans, noweDrinkIDs: noweDrinkIDs, context: modelContext)
            insertDrinkSpirits(drinkSpirits, noweDrinkIDs: noweDrinkIDs, context: modelContext)
            setAllDrinkKalorie(modelContext: modelContext)
            try? modelContext.save()
        }
        return true
    } catch {
        dprint("Błąd ładowania z Supabase: \(error)")
        return false
    }
}

// MARK: - Zmiana języka danych
//
// Przeładowuje treść w nowym języku, zachowując stan barku (sklStan)
// oraz ulubione. Notatki wracają z loadNotesFromSupabase.

func zmienJezykDanych(modelContext: ModelContext) async {
    // Zachowaj stan użytkownika + snapshot własnej treści (nie ma jej na serwerze)
    let (stany, ulubione, wlasneSkl, wlasneDr) = await MainActor.run {
        let skl = (try? modelContext.fetch(FetchDescriptor<Skl_M>())) ?? []
        let dr  = (try? modelContext.fetch(FetchDescriptor<Dr_M>())) ?? []
        let snap = snapshotWlasnejTresci(modelContext)
        return (
            Dictionary(uniqueKeysWithValues: skl.map { ($0.sklID, $0.sklStan) }),
            Dictionary(uniqueKeysWithValues: dr.map { ($0.drinkID, $0.drUlubiony) }),
            snap.0, snap.1
        )
    }

    // Wyczyść lokalną bazę
    await MainActor.run {
        try? modelContext.delete(model: Skl_M.self)
        try? modelContext.delete(model: Dr_M.self)
        try? modelContext.save()
    }

    // Załaduj ponownie w bieżącym języku (czytany z UserDefaults)
    await loadFromSupabase(modelContext: modelContext)

    // Przywróć stan użytkownika + własną treść (z zachowaniem stanu barku)
    await MainActor.run {
        let skl = (try? modelContext.fetch(FetchDescriptor<Skl_M>())) ?? []
        for s in skl { if let st = stany[s.sklID] { s.sklStan = st } }
        let dr = (try? modelContext.fetch(FetchDescriptor<Dr_M>())) ?? []
        for d in dr {
            if let u = ulubione[d.drinkID] { d.drUlubiony = u }
            d.setBrakiDrinka()
        }
        try? modelContext.save()
        przywrocWlasnaTresc(wlasneSkl, wlasneDr, resetujStan: false, ctx: modelContext)
    }
}

// MARK: - Zachowanie własnej treści (drinki i składniki użytkownika)
//
// Własne drinki (drZrodlo == "Własny") i składniki (sklWlasny) nie istnieją na
// serwerze, więc reload z Supabase by je usunął. Robimy więc ich snapshot do
// struktur wartościowych przed czyszczeniem bazy i odtwarzamy po reloadzie.

struct SnapSkl {
    let sklID, sklNazwa, sklKolor, sklFoto, sklOpis, sklWWW: String
    let sklKat: sklKatEnum
    let sklProc, sklKal: Int
    let sklMiara: miaraEnum
    let sklStan: sklStanEnum
}
struct SnapPoz {
    let sklID: String
    let sklNo: Int
    let sklIlosc: Double
    let sklMiara: miaraEnum
    let sklInfo: String
    let sklOpcja: Bool
}
struct SnapKrok { let przepNo: Int; let przepOpis: String; let przepOpcja: Bool }
struct SnapDrink {
    let drinkID, drNazwa, drZrodlo, drKolor, drFoto, drNotatka, drUwagi, drWWW: String
    let drKat: drKatEnum
    let drSlodycz: drSlodyczEnum
    let drSzklo: szkloEnum
    let drMoc: drMocEnum
    let drProc, drKal: Int
    let drUlubiony: Bool
    let drAlkGlowny: [alkGlownyEnum]
    let pozycje: [SnapPoz]
    let kroki: [SnapKrok]
}

// Zbiera własne składniki i drinki do struktur wartościowych. Wołać na MainActor.
func snapshotWlasnejTresci(_ ctx: ModelContext) -> ([SnapSkl], [SnapDrink]) {
    let skl = ((try? ctx.fetch(FetchDescriptor<Skl_M>())) ?? []).filter { $0.sklWlasny }
    let snapSkl = skl.map {
        SnapSkl(sklID: $0.sklID, sklNazwa: $0.sklNazwa, sklKolor: $0.sklKolor,
                sklFoto: $0.sklFoto, sklOpis: $0.sklOpis, sklWWW: $0.sklWWW,
                sklKat: $0.sklKat, sklProc: $0.sklProc, sklKal: $0.sklKal,
                sklMiara: $0.sklMiara, sklStan: $0.sklStan)
    }
    let dr = ((try? ctx.fetch(FetchDescriptor<Dr_M>())) ?? []).filter { $0.drZrodlo == "Własny" }
    let snapDr = dr.map { d in
        SnapDrink(
            drinkID: d.drinkID, drNazwa: d.drNazwa, drZrodlo: d.drZrodlo, drKolor: d.drKolor,
            drFoto: d.drFoto, drNotatka: d.drNotatka, drUwagi: d.drUwagi, drWWW: d.drWWW,
            drKat: d.drKat, drSlodycz: d.drSlodycz, drSzklo: d.drSzklo, drMoc: d.drMoc,
            drProc: d.drProc, drKal: d.drKal, drUlubiony: d.drUlubiony,
            drAlkGlowny: d.drAlkGlowny,
            pozycje: d.drSklad.map {
                SnapPoz(sklID: $0.skladnik.sklID, sklNo: $0.sklNo, sklIlosc: $0.sklIlosc,
                        sklMiara: $0.sklMiara, sklInfo: $0.sklInfo, sklOpcja: $0.sklOpcja)
            },
            kroki: d.drPrzepis.map {
                SnapKrok(przepNo: $0.przepNo, przepOpis: $0.przepOpis, przepOpcja: $0.przepOpcja)
            }
        )
    }
    return (snapSkl, snapDr)
}

// Odtwarza własne składniki i drinki, których nie ma po reloadzie. Wołać na MainActor.
// resetujStan == true → własne składniki wracają ze stanem .brak (jak przy resecie barku).
func przywrocWlasnaTresc(_ skl: [SnapSkl], _ dr: [SnapDrink], resetujStan: Bool, ctx: ModelContext) {
    guard !skl.isEmpty || !dr.isEmpty else { return }

    var mapa = Dictionary(uniqueKeysWithValues:
        ((try? ctx.fetch(FetchDescriptor<Skl_M>())) ?? []).map { ($0.sklID, $0) })

    // Odtwórz brakujące własne składniki
    for s in skl where mapa[s.sklID] == nil {
        let nowy = Skl_M(
            sklID: s.sklID, sklNazwa: s.sklNazwa, sklKat: s.sklKat, sklProc: s.sklProc,
            sklKolor: s.sklKolor, sklFoto: s.sklFoto, sklStan: resetujStan ? .brak : s.sklStan,
            sklOpis: s.sklOpis, sklKal: s.sklKal, sklMiara: s.sklMiara, sklWWW: s.sklWWW
        )
        nowy.sklWlasny = true
        ctx.insert(nowy)
        mapa[s.sklID] = nowy
    }

    // Odtwórz brakujące własne drinki (z pozycjami i krokami)
    let istniejaceDrinki = Set(((try? ctx.fetch(FetchDescriptor<Dr_M>())) ?? []).map { $0.drinkID })
    for d in dr where !istniejaceDrinki.contains(d.drinkID) {
        let drink = Dr_M(
            drinkID: d.drinkID, drNazwa: d.drNazwa, drKat: d.drKat, drZrodlo: d.drZrodlo,
            drKolor: d.drKolor, drFoto: d.drFoto, drProc: d.drProc, drSlodycz: d.drSlodycz,
            drSzklo: d.drSzklo, drUlubiony: d.drUlubiony, drNotatka: d.drNotatka, drUwagi: d.drUwagi,
            drWWW: d.drWWW, drKal: d.drKal, drMoc: d.drMoc, drBrakuje: 0, drAlkGlowny: d.drAlkGlowny,
            drSklad: [], drPrzepis: []
        )
        ctx.insert(drink)
        for p in d.pozycje {
            guard let sklad = mapa[p.sklID] else { continue }
            ctx.insert(DrSkladnik_M(relacjaDrink: drink, skladnik: sklad, sklNo: p.sklNo,
                                    sklIlosc: p.sklIlosc, sklMiara: p.sklMiara,
                                    sklInfo: p.sklInfo, sklOpcja: p.sklOpcja))
        }
        for k in d.kroki {
            ctx.insert(DrPrzepis_M(relacjaDrink: drink, drinkID: d.drinkID, przepNo: k.przepNo,
                                   przepOpis: k.przepOpis, przepOpcja: k.przepOpcja))
        }
        drink.setBrakiDrinka()
    }
    try? ctx.save()
}

// MARK: - Fetch z Supabase

private func fetchIngredients() async throws -> [IngredientDTO] {
    try await supabase.from("ingredients").select().execute().value
}

private func fetchSubstitutes() async throws -> [IngredientSubstituteDTO] {
    try await supabase.from("ingredient_substitutes").select().execute().value
}

private func fetchDrinks() async throws -> [DrinkDTO] {
    try await supabase.from("drinks").select().execute().value
}

private func fetchDrinkIngredients() async throws -> [DrinkIngredientDTO] {
    try await supabase.from("drink_ingredients").select().execute().value
}

private func fetchDrinkSteps() async throws -> [DrinkStepDTO] {
    try await supabase.from("drink_steps").select().execute().value
}

private func fetchDrinkSpirits() async throws -> [DrinkSpiritDTO] {
    try await supabase.from("drink_spirits").select().execute().value
}

// MARK: - Tłumaczenia

struct Tlumaczenia {
    var drinki:    [String: DrinkTranslationDTO] = [:]            // klucz: drinkId
    var kroki:     [String: DrinkStepTranslationDTO] = [:]        // klucz: "drinkId|stepNo"
    var pozycje:   [String: DrinkIngredientTranslationDTO] = [:]  // klucz: "drinkId|ingredientId"
    var skladniki: [String: IngredientTranslationDTO] = [:]       // klucz: ingredientId
}

private func fetchTlumaczenia(lang: String) async throws -> Tlumaczenia {
    async let dr: [DrinkTranslationDTO]           = supabase.from("drink_translations").select().eq("lang", value: lang).execute().value
    async let st: [DrinkStepTranslationDTO]       = supabase.from("drink_step_translations").select().eq("lang", value: lang).execute().value
    async let di: [DrinkIngredientTranslationDTO] = supabase.from("drink_ingredient_translations").select().eq("lang", value: lang).execute().value
    async let sk: [IngredientTranslationDTO]      = supabase.from("ingredient_translations").select().eq("lang", value: lang).execute().value

    let (drinki, kroki, pozycje, skladniki) = try await (dr, st, di, sk)

    var t = Tlumaczenia()
    for x in drinki    { t.drinki[x.drinkId] = x }
    for x in kroki     { t.kroki["\(x.drinkId)|\(x.stepNo)"] = x }
    for x in pozycje   { t.pozycje["\(x.drinkId)|\(x.ingredientId)"] = x }
    for x in skladniki { t.skladniki[x.ingredientId] = x }
    return t
}

// Zwraca tłumaczenie jeśli niepuste, w przeciwnym razie wartość bazową (PL)
private func wybierz(_ tlumaczenie: String?, _ baza: String) -> String {
    if let t = tlumaczenie, !t.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return t }
    return baza
}

// MARK: - Insert do SwiftData

private func insertIngredients(_ dtos: [IngredientDTO], trans: Tlumaczenia, context: ModelContext) {
    let istniejace = Set(fetchAllSkladniki(context: context).keys)
    for dto in dtos {
        if istniejace.contains(dto.id) { continue }
        let tr = trans.skladniki[dto.id]
        let skl = Skl_M(
            sklID:    dto.id,
            sklNazwa: wybierz(tr?.name, dto.name),
            sklKat:   strToSklKatEnum(dto.category ?? ""),
            sklProc:  dto.alcoholPct ?? 0,
            sklKolor: dto.color ?? "",
            sklFoto:  dto.photo ?? "",
            sklStan:  .brak,
            sklOpis:  wybierz(tr?.description, dto.description ?? ""),
            sklKal:   dto.calories ?? 0,
            sklMiara: strToSklMiaraEnum(dto.unit ?? ""),
            sklWWW:   dto.url ?? ""
        )
        context.insert(skl)
    }
}

@discardableResult
private func insertDrinks(_ dtos: [DrinkDTO], trans: Tlumaczenia, context: ModelContext) -> Set<String> {
    let istniejace = Set(fetchAllDrinks(context: context).keys)
    var nowe: Set<String> = []
    for dto in dtos {
        if istniejace.contains(dto.id) { continue }
        nowe.insert(dto.id)
        let tr = trans.drinki[dto.id]
        let dr = Dr_M(
            drinkID:   dto.id,
            drNazwa:   wybierz(tr?.name, dto.name),
            drKat:     strToDrKatEnum(dto.category ?? ""),
            drZrodlo:  dto.source ?? "",
            drKolor:   dto.color ?? "",
            drFoto:    dto.photo ?? (strToDrSzklo(dto.glass ?? "").foto),
            drProc:    dto.alcoholPct ?? 0,
            drSlodycz: strToDrSlodycz(dto.sweetness ?? ""),
            drSzklo:   strToDrSzklo(dto.glass ?? ""),
            drUlubiony: dto.favorite ?? false,
            drNotatka: wybierz(tr?.note, dto.note ?? ""),
            drUwagi:   wybierz(tr?.remarks, dto.remarks ?? ""),
            drWWW:     dto.url ?? "",
            drKal:     dto.calories ?? 0,
            drMoc:     valToDrMoc(String(dto.alcoholPct ?? 0)),
            drBrakuje: 0,
            drAlkGlowny: [],
            drSklad:   [],
            drPrzepis: []
        )
        context.insert(dr)
    }
    return nowe
}

private func insertDrinkIngredients(
    _ dtos: [DrinkIngredientDTO],
    substitutes: [IngredientSubstituteDTO],
    trans: Tlumaczenia,
    noweDrinkIDs: Set<String>,
    context: ModelContext
) {
    let drinkMap = fetchAllDrinks(context: context)
    let sklMap   = fetchAllSkladniki(context: context)

    // Zamienniki — addZamiennik pomija duplikaty, więc bezpieczne przy reloadzie
    for sub in substitutes {
        guard let skl = sklMap[sub.ingredientId],
              let zam = sklMap[sub.substituteId] else { continue }
        skl.addZamiennik(zam)
    }

    for dto in dtos {
        guard noweDrinkIDs.contains(dto.drinkId),
              let drink = drinkMap[dto.drinkId],
              let skl   = sklMap[dto.ingredientId] else { continue }
        let tr = trans.pozycje["\(dto.drinkId)|\(dto.ingredientId)"]
        let pozycja = DrSkladnik_M(
            relacjaDrink: drink,
            skladnik:     skl,
            sklNo:        dto.sortOrder ?? 0,
            sklIlosc:     dto.amount ?? 0,
            sklMiara:     strToSklMiaraEnum(dto.unit ?? ""),
            sklInfo:      wybierz(tr?.info, dto.info ?? ""),
            sklOpcja:     dto.optional ?? false
        )
        context.insert(pozycja)
    }

    // Przelicz braki po załadowaniu składników
    for drink in drinkMap.values { drink.setBrakiDrinka() }
}

private func insertDrinkSteps(_ dtos: [DrinkStepDTO], trans: Tlumaczenia, noweDrinkIDs: Set<String>, context: ModelContext) {
    let drinkMap = fetchAllDrinks(context: context)
    for dto in dtos {
        guard noweDrinkIDs.contains(dto.drinkId),
              let drink = drinkMap[dto.drinkId] else { continue }
        let tr = trans.kroki["\(dto.drinkId)|\(dto.stepNo)"]
        let krok = DrPrzepis_M(
            relacjaDrink: drink,
            drinkID:      dto.drinkId,
            przepNo:      dto.stepNo,
            przepOpis:    wybierz(tr?.description, dto.description ?? ""),
            przepOpcja:   dto.optional ?? false
        )
        context.insert(krok)
    }
}

private func insertDrinkSpirits(_ dtos: [DrinkSpiritDTO], noweDrinkIDs: Set<String>, context: ModelContext) {
    let drinkMap = fetchAllDrinks(context: context)
    for dto in dtos {
        guard noweDrinkIDs.contains(dto.drinkId),
              let drink = drinkMap[dto.drinkId] else { continue }
        if let alkohol = alkGlownyEnum(rawValue: dto.spirit) {
            drink.drAlkGlowny.append(alkohol)
        }
    }
}

// MARK: - Pomocnicze: słowniki ze SwiftData

private func fetchAllDrinks(context: ModelContext) -> [String: Dr_M] {
    let all = (try? context.fetch(FetchDescriptor<Dr_M>())) ?? []
    return Dictionary(uniqueKeysWithValues: all.map { ($0.drinkID, $0) })
}

private func fetchAllSkladniki(context: ModelContext) -> [String: Skl_M] {
    let all = (try? context.fetch(FetchDescriptor<Skl_M>())) ?? []
    return Dictionary(uniqueKeysWithValues: all.map { ($0.sklID, $0) })
}
