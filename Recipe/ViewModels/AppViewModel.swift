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

    @Published var checkedIngredientsByRecipeID: [String: [String]] = [:]

    @Published var isLoadingHome = false
    @Published var isSearching = false
    @Published var errorMessage: String?

    private let accountsKey = "recipeapp.accounts"

    private var registeredUsers: [UserAccount] = []

    var isSignedIn: Bool {
        signedInUser != nil
    }

    init() {
        registeredUsers = loadRegisteredUsers()
    }

    // MARK: - Auth

    func signIn(email: String, password: String) {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !cleanEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password."
            return
        }

        guard let user = registeredUsers.first(where: { $0.email == cleanEmail }) else {
            errorMessage = "No account found with this email. Please sign up first."
            return
        }

        guard user.password == password else {
            errorMessage = "Incorrect password."
            return
        }

        signedInUser = user
        errorMessage = nil
        loadCurrentUserData()
    }

    func signUp(email: String, password: String) {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !cleanEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password."
            return
        }

        guard !registeredUsers.contains(where: { $0.email == cleanEmail }) else {
            errorMessage = "This email is already registered. Please sign in."
            return
        }

        let newUser = UserAccount(email: cleanEmail, password: password)
        registeredUsers.append(newUser)
        saveRegisteredUsers()

        signedInUser = newUser
        errorMessage = nil

        favoriteRecipes = []
        addedRecipes = []
        homeRecipes = []
        searchResults = []
        checkedIngredientsByRecipeID = [:]

        saveCurrentUserData()
    }

    func signOut() {
        saveCurrentUserData()

        signedInUser = nil
        homeRecipes = []
        searchResults = []
        favoriteRecipes = []
        addedRecipes = []
        checkedIngredientsByRecipeID = [:]
        errorMessage = nil
    }

    // MARK: - Home Recipes

    func loadHomeRecipes() async {
        guard homeRecipes.isEmpty else { return }

        isLoadingHome = true
        homeRecipes = await RecipeAPIService.shared.randomRecipes(count: 12)
        isLoadingHome = false
    }

    func reloadHomeRecipes() async {
        isLoadingHome = true
        homeRecipes = await RecipeAPIService.shared.randomRecipes(count: 12)
        isLoadingHome = false
    }

    // MARK: - Search

    func searchRecipes(query: String) async {
        let cleanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanQuery.isEmpty else {
            searchResults = []
            await loadRecommendations(forceReload: true)
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

    func loadRecommendations(forceReload: Bool = false) async {
        if !forceReload && !searchResults.isEmpty {
            return
        }

        searchResults = await RecipeAPIService.shared.randomRecipes(count: 8)
    }

    // MARK: - My Recipes

    func addLocalRecipe(_ recipe: Recipe) {
        addedRecipes.insert(recipe, at: 0)
        saveCurrentUserData()
    }

    func updateLocalRecipe(_ updatedRecipe: Recipe) {
        if let index = addedRecipes.firstIndex(where: { $0.id == updatedRecipe.id }) {
            addedRecipes[index] = updatedRecipe
        }

        if let favoriteIndex = favoriteRecipes.firstIndex(where: { $0.id == updatedRecipe.id }) {
            favoriteRecipes[favoriteIndex] = updatedRecipe
        }

        saveCurrentUserData()
    }

    func deleteLocalRecipe(_ recipe: Recipe) {
        addedRecipes.removeAll { $0.id == recipe.id }
        favoriteRecipes.removeAll { $0.id == recipe.id }
        checkedIngredientsByRecipeID[recipe.id] = nil

        saveCurrentUserData()
    }
    
    func isMyRecipe(_ recipe: Recipe) -> Bool {
        addedRecipes.contains(where: { $0.id == recipe.id })
    }

    // MARK: - Favorites

    func toggleFavorite(_ recipe: Recipe) {
        if let index = favoriteRecipes.firstIndex(where: { $0.id == recipe.id }) {
            favoriteRecipes.remove(at: index)
            checkedIngredientsByRecipeID[recipe.id] = nil
        } else {
            favoriteRecipes.append(recipe)
        }

        saveCurrentUserData()
    }

    func isFavorite(_ recipe: Recipe) -> Bool {
        favoriteRecipes.contains(where: { $0.id == recipe.id })
    }

    // MARK: - Ingredient Checkbox Saving

    func ingredientKey(_ ingredient: Ingredient) -> String {
        "\(ingredient.name)|\(ingredient.measure)"
    }

    func isIngredientChecked(recipe: Recipe, ingredient: Ingredient) -> Bool {
        let key = ingredientKey(ingredient)
        return checkedIngredientsByRecipeID[recipe.id]?.contains(key) ?? false
    }

    func toggleIngredientChecked(recipe: Recipe, ingredient: Ingredient) {
        guard isFavorite(recipe) else {
            errorMessage = "Add this recipe to favorites to save checked ingredients."
            return
        }

        let key = ingredientKey(ingredient)
        var checkedKeys = checkedIngredientsByRecipeID[recipe.id] ?? []

        if checkedKeys.contains(key) {
            checkedKeys.removeAll { $0 == key }
        } else {
            checkedKeys.append(key)
        }

        checkedIngredientsByRecipeID[recipe.id] = checkedKeys
        saveCurrentUserData()
    }

    // MARK: - Storage

    private struct UserStoredData: Codable {
        var favoriteRecipes: [Recipe]
        var addedRecipes: [Recipe]
        var checkedIngredientsByRecipeID: [String: [String]]
    }

    private func userDataKey(for email: String) -> String {
        "recipeapp.userdata.\(email)"
    }

    private func loadRegisteredUsers() -> [UserAccount] {
        guard let data = UserDefaults.standard.data(forKey: accountsKey) else {
            return []
        }

        return (try? JSONDecoder().decode([UserAccount].self, from: data)) ?? []
    }

    private func saveRegisteredUsers() {
        guard let data = try? JSONEncoder().encode(registeredUsers) else {
            return
        }

        UserDefaults.standard.set(data, forKey: accountsKey)
    }

    private func loadCurrentUserData() {
        guard let signedInUser else { return }

        let key = userDataKey(for: signedInUser.email)

        guard let data = UserDefaults.standard.data(forKey: key),
              let storedData = try? JSONDecoder().decode(UserStoredData.self, from: data) else {
            favoriteRecipes = []
            addedRecipes = []
            homeRecipes = []
            searchResults = []
            checkedIngredientsByRecipeID = [:]
            return
        }

        favoriteRecipes = storedData.favoriteRecipes
        addedRecipes = storedData.addedRecipes
        checkedIngredientsByRecipeID = storedData.checkedIngredientsByRecipeID
        homeRecipes = []
        searchResults = []
    }

    private func saveCurrentUserData() {
        guard let signedInUser else { return }

        let storedData = UserStoredData(
            favoriteRecipes: favoriteRecipes,
            addedRecipes: addedRecipes,
            checkedIngredientsByRecipeID: checkedIngredientsByRecipeID
        )

        guard let data = try? JSONEncoder().encode(storedData) else {
            return
        }

        let key = userDataKey(for: signedInUser.email)
        UserDefaults.standard.set(data, forKey: key)
    }
}
