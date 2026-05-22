//
//  Recipe.swift
//  Recipe
//
//  Created by Мирас Нуралиев on 22.05.2026.
//

import Foundation

struct Recipe: Identifiable, Equatable {
    let id: String
    let name: String
    let imageURL: String?
    let category: String?
    let area: String?
    let instructions: String?
    let ingredients: [Ingredient]
    var localImageData: Data? = nil

    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.id == rhs.id
    }
}

struct Ingredient: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let measure: String
    var isChecked: Bool = false
}

// MARK: - TheMealDB API Models

struct MealDBResponse: Decodable {
    let meals: [MealDBMeal]?
}

struct MealDBMeal: Decodable {
    let idMeal: String?
    let strMeal: String?
    let strCategory: String?
    let strArea: String?
    let strInstructions: String?
    let strMealThumb: String?

    let strIngredient1: String?
    let strIngredient2: String?
    let strIngredient3: String?
    let strIngredient4: String?
    let strIngredient5: String?
    let strIngredient6: String?
    let strIngredient7: String?
    let strIngredient8: String?
    let strIngredient9: String?
    let strIngredient10: String?
    let strIngredient11: String?
    let strIngredient12: String?
    let strIngredient13: String?
    let strIngredient14: String?
    let strIngredient15: String?
    let strIngredient16: String?
    let strIngredient17: String?
    let strIngredient18: String?
    let strIngredient19: String?
    let strIngredient20: String?

    let strMeasure1: String?
    let strMeasure2: String?
    let strMeasure3: String?
    let strMeasure4: String?
    let strMeasure5: String?
    let strMeasure6: String?
    let strMeasure7: String?
    let strMeasure8: String?
    let strMeasure9: String?
    let strMeasure10: String?
    let strMeasure11: String?
    let strMeasure12: String?
    let strMeasure13: String?
    let strMeasure14: String?
    let strMeasure15: String?
    let strMeasure16: String?
    let strMeasure17: String?
    let strMeasure18: String?
    let strMeasure19: String?
    let strMeasure20: String?

    var recipe: Recipe {
        let ingredientNames = [
            strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5,
            strIngredient6, strIngredient7, strIngredient8, strIngredient9, strIngredient10,
            strIngredient11, strIngredient12, strIngredient13, strIngredient14, strIngredient15,
            strIngredient16, strIngredient17, strIngredient18, strIngredient19, strIngredient20
        ]

        let measures = [
            strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5,
            strMeasure6, strMeasure7, strMeasure8, strMeasure9, strMeasure10,
            strMeasure11, strMeasure12, strMeasure13, strMeasure14, strMeasure15,
            strMeasure16, strMeasure17, strMeasure18, strMeasure19, strMeasure20
        ]

        let ingredients = zip(ingredientNames, measures).compactMap { name, measure -> Ingredient? in
            let cleanName = (name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let cleanMeasure = (measure ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

            guard !cleanName.isEmpty else {
                return nil
            }

            return Ingredient(name: cleanName, measure: cleanMeasure)
        }

        return Recipe(
            id: idMeal ?? UUID().uuidString,
            name: strMeal ?? "Unknown Recipe",
            imageURL: strMealThumb,
            category: strCategory,
            area: strArea,
            instructions: strInstructions,
            ingredients: ingredients
        )
    }
}
