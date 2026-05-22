//
//  AppViewModel.swift
//  Recipe
//
//  Created by Мирас Нуралиев on 22.05.2026.
//

import Foundation
import Combine

@MainActor
final class AppViewModel: ObservableObject {
    @Published var signedInUser: UserAccount?

    @Published var homeRecipes: [Recipe] = []
    @Published var searchResults: [Recipe] = []
    @Published var favoriteRecipes: [Recipe] = []
    @Published var addedRecipes: [Recipe] = []

    @Published var isLoadingHome = false
    @Published var isSearching = false
    @Published var errorMessage: String?

    var isSignedIn: Bool {
        signedInUser != nil
    }

    func signIn(email: String, password: String) {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password."
            return
        }

        signedInUser = UserAccount(email: cleanEmail)
        errorMessage = nil
    }

    func signUp(email: String, password: String) {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password."
            return
        }

        signedInUser = UserAccount(email: cleanEmail)
        errorMessage = nil
    }

    func signOut() {
        signedInUser = nil
    }

    func loadHomeRecipes() async {
        guard homeRecipes.isEmpty else { return }

        isLoadingHome = true
        let recipes = await RecipeAPIService.shared.randomRecipes(count: 12)
        homeRecipes = recipes
        isLoadingHome = false
    }

    func reloadHomeRecipes() async {
        homeRecipes.removeAll()
        await loadHomeRecipes()
    }

    func searchRecipes(query: String) async {
        let cleanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanQuery.isEmpty else {
            searchResults = []
            await loadRecommendations()
            return
        }

        isSearching = true

        do {
            searchResults = try await RecipeAPIService.shared.searchRecipes(query: cleanQuery)
        } catch {
            errorMessage = "Could not load recipes. Please try again."
        }

        isSearching = false
    }

    func loadRecommendations() async {
        guard searchResults.isEmpty else { return }

        searchResults = await RecipeAPIService.shared.randomRecipes(count: 8)
    }

    func toggleFavorite(_ recipe: Recipe) {
        if let index = favoriteRecipes.firstIndex(where: { $0.id == recipe.id }) {
            favoriteRecipes.remove(at: index)
        } else {
            favoriteRecipes.append(recipe)
        }
    }

    func isFavorite(_ recipe: Recipe) -> Bool {
        favoriteRecipes.contains(where: { $0.id == recipe.id })
    }

    func addLocalRecipe(_ recipe: Recipe) {
        addedRecipes.insert(recipe, at: 0)
        homeRecipes.insert(recipe, at: 0)
    }
}
