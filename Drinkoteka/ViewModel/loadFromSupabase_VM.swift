import SwiftData
import Foundation

// MARK: - Główna funkcja ładowania

func loadFromSupabase(modelContext: ModelContext) async {
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

        // Wstawiamy na głównym wątku (ModelContext nie jest thread-safe)
        await MainActor.run {
            insertIngredients(ingredients, context: modelContext)
            insertDrinks(drinks, context: modelContext)
            insertDrinkIngredients(drinkIngredients, substitutes: substitutes, context: modelContext)
            insertDrinkSteps(drinkSteps, context: modelContext)
            insertDrinkSpirits(drinkSpirits, context: modelContext)
            try? modelContext.save()
        }
    } catch {
        print("Błąd ładowania z Supabase: \(error)")
    }
}

// MARK: - Fetch z Supabase

private func fetchIngredients() async throws -> [IngredientDTO] {
    try await supabase
        .from("ingredients")
        .select()
        .execute()
        .value
}

private func fetchSubstitutes() async throws -> [IngredientSubstituteDTO] {
    try await supabase
        .from("ingredient_substitutes")
        .select()
        .execute()
        .value
}

private func fetchDrinks() async throws -> [DrinkDTO] {
    try await supabase
        .from("drinks")
        .select()
        .execute()
        .value
}

private func fetchDrinkIngredients() async throws -> [DrinkIngredientDTO] {
    try await supabase
        .from("drink_ingredients")
        .select()
        .execute()
        .value
}

private func fetchDrinkSteps() async throws -> [DrinkStepDTO] {
    try await supabase
        .from("drink_steps")
        .select()
        .execute()
        .value
}

private func fetchDrinkSpirits() async throws -> [DrinkSpiritDTO] {
    try await supabase
        .from("drink_spirits")
        .select()
        .execute()
        .value
}

// MARK: - Insert do SwiftData

private func insertIngredients(_ dtos: [IngredientDTO], context: ModelContext) {
    for dto in dtos {
        let skl = Skl_M(
            sklID:    dto.id,
            sklNazwa: dto.name,
            sklKat:   strToSklKatEnum(dto.category ?? ""),
            sklProc:  dto.alcoholPct ?? 0,
            sklKolor: dto.color ?? "",
            sklFoto:  dto.photo ?? "",
            sklStan:  .brak,
            sklOpis:  dto.description ?? "",
            sklKal:   dto.calories ?? 0,
            sklMiara: strToSklMiaraEnum(dto.unit ?? ""),
            sklWWW:   dto.url ?? ""
        )
        context.insert(skl)
    }
}

private func insertDrinks(_ dtos: [DrinkDTO], context: ModelContext) {
    for dto in dtos {
        let dr = Dr_M(
            drinkID:   dto.id,
            drNazwa:   dto.name,
            drKat:     strToDrKatEnum(dto.category ?? ""),
            drZrodlo:  dto.source ?? "",
            drKolor:   dto.color ?? "",
            drFoto:    dto.photo ?? (strToDrSzklo(dto.glass ?? "").foto),
            drProc:    dto.alcoholPct ?? 0,
            drSlodycz: strToDrSlodycz(dto.sweetness ?? ""),
            drSzklo:   strToDrSzklo(dto.glass ?? ""),
            drUlubiony: dto.favorite ?? false,
            drNotatka: dto.note ?? "",
            drUwagi:   dto.remarks ?? "",
            drWWW:     dto.url ?? "",
            drKal:     dto.calories ?? 0,
            drMoc:     valToDrMoc(String(dto.alcoholPct ?? 0)),
            drBrakuje: 0,
            drAlkGlowny: [],
            drSklad:   [],
            drPrzepis: [],
            drPolecany: dto.recommended ?? false
        )
        context.insert(dr)
    }
}

private func insertDrinkIngredients(
    _ dtos: [DrinkIngredientDTO],
    substitutes: [IngredientSubstituteDTO],
    context: ModelContext
) {
    let drinkMap = fetchAllDrinks(context: context)
    let sklMap   = fetchAllSkladniki(context: context)

    // Zamienniki — najpierw uzupełnij stan Skl_M
    for sub in substitutes {
        guard let skl = sklMap[sub.ingredientId],
              let zam = sklMap[sub.substituteId] else { continue }
        skl.addZamiennik(zam)
    }

    for dto in dtos {
        guard let drink = drinkMap[dto.drinkId],
              let skl   = sklMap[dto.ingredientId] else { continue }
        let pozycja = DrSkladnik_M(
            relacjaDrink: drink,
            skladnik:     skl,
            sklNo:        dto.sortOrder ?? 0,
            sklIlosc:     dto.amount ?? 0,
            sklMiara:     strToSklMiaraEnum(dto.unit ?? ""),
            sklInfo:      dto.info ?? "",
            sklOpcja:     dto.optional ?? false
        )
        context.insert(pozycja)
    }

    // Przelicz braki po załadowaniu składników
    for drink in drinkMap.values { drink.setBrakiDrinka() }
}

private func insertDrinkSteps(_ dtos: [DrinkStepDTO], context: ModelContext) {
    let drinkMap = fetchAllDrinks(context: context)
    for dto in dtos {
        guard let drink = drinkMap[dto.drinkId] else { continue }
        let krok = DrPrzepis_M(
            relacjaDrink: drink,
            drinkID:      dto.drinkId,
            przepNo:      dto.stepNo,
            przepOpis:    dto.description ?? "",
            przepOpcja:   dto.optional ?? false
        )
        context.insert(krok)
    }
}

private func insertDrinkSpirits(_ dtos: [DrinkSpiritDTO], context: ModelContext) {
    let drinkMap = fetchAllDrinks(context: context)
    for dto in dtos {
        guard let drink = drinkMap[dto.drinkId] else { continue }
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
