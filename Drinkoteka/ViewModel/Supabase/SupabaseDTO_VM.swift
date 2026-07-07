// DTO (Codable) mapujące wiersze tabel Supabase (snake_case) na typy Swift.
// Używane przez loadFromSupabase i warstwę tłumaczeń.
import Foundation

// MARK: - Ingredient

struct IngredientDTO: Codable {
    let id: String
    let name: String
    let category: String?
    let alcoholPct: Int?
    let color: String?
    let photo: String?
    let description: String?
    let calories: Int?
    let unit: String?
    let url: String?

    enum CodingKeys: String, CodingKey {
        case id, name, category, color, photo, description, calories, unit, url
        case alcoholPct = "alcohol_pct"
    }
}

// MARK: - Ingredient Substitute

struct IngredientSubstituteDTO: Codable {
    let ingredientId: String
    let substituteId: String

    enum CodingKeys: String, CodingKey {
        case ingredientId = "ingredient_id"
        case substituteId = "substitute_id"
    }
}

// MARK: - Drink

struct DrinkDTO: Codable {
    let id: String
    let name: String
    let category: String?
    let source: String?
    let color: String?
    let photo: String?
    let alcoholPct: Int?
    let sweetness: String?
    let glass: String?
    let favorite: Bool?
    let note: String?
    let remarks: String?
    let url: String?
    let calories: Int?
    let recommended: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, category, source, color, photo, sweetness, glass, favorite, note, remarks, url, calories, recommended
        case alcoholPct = "alcohol_pct"
    }
}

// MARK: - Drink Ingredient

struct DrinkIngredientDTO: Codable {
    let drinkId: String
    let ingredientId: String
    let amount: Double?
    let unit: String?
    let info: String?
    let optional: Bool?
    let sortOrder: Int?

    enum CodingKeys: String, CodingKey {
        case amount, unit, info, optional
        case drinkId = "drink_id"
        case ingredientId = "ingredient_id"
        case sortOrder = "sort_order"
    }
}

// MARK: - Drink Step

struct DrinkStepDTO: Codable {
    let drinkId: String
    let stepNo: Int
    let description: String?
    let optional: Bool?

    enum CodingKeys: String, CodingKey {
        case description, optional
        case drinkId = "drink_id"
        case stepNo = "step_no"
    }
}

// MARK: - Drink Spirit

struct DrinkSpiritDTO: Codable {
    let drinkId: String
    let spirit: String

    enum CodingKeys: String, CodingKey {
        case spirit
        case drinkId = "drink_id"
    }
}

// MARK: - Tłumaczenia

struct DrinkTranslationDTO: Codable {
    let drinkId: String
    let lang: String
    let name: String?
    let note: String?
    let remarks: String?

    enum CodingKeys: String, CodingKey {
        case lang, name, note, remarks
        case drinkId = "drink_id"
    }
}

struct DrinkStepTranslationDTO: Codable {
    let drinkId: String
    let stepNo: Int
    let lang: String
    let description: String?

    enum CodingKeys: String, CodingKey {
        case lang, description
        case drinkId = "drink_id"
        case stepNo = "step_no"
    }
}

struct DrinkIngredientTranslationDTO: Codable {
    let drinkId: String
    let ingredientId: String
    let lang: String
    let info: String?

    enum CodingKeys: String, CodingKey {
        case lang, info
        case drinkId = "drink_id"
        case ingredientId = "ingredient_id"
    }
}

struct IngredientTranslationDTO: Codable {
    let ingredientId: String
    let lang: String
    let name: String?
    let description: String?

    enum CodingKeys: String, CodingKey {
        case lang, name, description
        case ingredientId = "ingredient_id"
    }
}
