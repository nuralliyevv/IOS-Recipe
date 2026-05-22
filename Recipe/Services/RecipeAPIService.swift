//
//  RecipeAPIService.swift
//  Recipe
//
//  Created by Мирас Нуралиев on 22.05.2026.
//

import Foundation

final class RecipeAPIService {
    static let shared = RecipeAPIService()

    private let baseURL = "https://www.themealdb.com/api/json/v1/1"

    private init() {}

    func searchRecipes(query: String) async throws -> [Recipe] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = URL(string: "\(baseURL)/search.php?s=\(encodedQuery)")!

        let response: MealDBResponse = try await fetch(url)
        return response.meals?.map { $0.recipe } ?? []
    }

    func randomRecipe() async throws -> Recipe? {
        let url = URL(string: "\(baseURL)/random.php")!

        let response: MealDBResponse = try await fetch(url)
        return response.meals?.first?.recipe
    }

    func randomRecipes(count: Int) async -> [Recipe] {
        var recipes: [Recipe] = []

        await withTaskGroup(of: Recipe?.self) { group in
            for _ in 0..<count {
                group.addTask {
                    try? await self.randomRecipe()
                }
            }

            for await recipe in group {
                guard let recipe else { continue }

                if !recipes.contains(where: { $0.id == recipe.id }) {
                    recipes.append(recipe)
                }
            }
        }

        return recipes
    }

    private func fetch<T: Decodable>(_ url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}
