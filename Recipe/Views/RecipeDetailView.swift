//
//  RecipeDetailView.swift
//  Recipe
//
//  Created by Мирас Нуралиев on 22.05.2026.
//

import SwiftUI

struct RecipeDetailView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    let recipe: Recipe

    @State private var showDeleteAlert = false

    var currentRecipe: Recipe {
        if let updatedRecipe = viewModel.addedRecipes.first(where: { $0.id == recipe.id }) {
            return updatedRecipe
        }

        if let updatedFavorite = viewModel.favoriteRecipes.first(where: { $0.id == recipe.id }) {
            return updatedFavorite
        }

        return recipe
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                RecipeImageView(recipe: currentRecipe)
                    .frame(height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .overlay(alignment: .topTrailing) {
                        Button {
                            viewModel.toggleFavorite(currentRecipe)
                        } label: {
                            Image(systemName: viewModel.isFavorite(currentRecipe) ? "heart.fill" : "heart")
                                .font(.title2)
                                .padding(10)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .foregroundStyle(viewModel.isFavorite(currentRecipe) ? .red : .primary)
                        }
                        .padding()
                    }

                if viewModel.isMyRecipe(currentRecipe) {
                    HStack(spacing: 12) {
                        NavigationLink {
                            EditRecipeView(recipe: currentRecipe)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.orange.opacity(0.15))
                                .foregroundStyle(.orange)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.red.opacity(0.12))
                                .foregroundStyle(.red)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                }

                Text(currentRecipe.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                HStack {
                    if let category = currentRecipe.category, !category.isEmpty {
                        Label(category, systemImage: "tag")
                    }

                    if let area = currentRecipe.area, !area.isEmpty {
                        Label(area, systemImage: "globe")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                if !viewModel.isFavorite(currentRecipe) {
                    Text("Add this recipe to favorites to save ingredient checkboxes.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 4)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Ingredients")
                        .font(.title2)
                        .fontWeight(.bold)

                    ForEach(currentRecipe.ingredients) { ingredient in
                        Button {
                            viewModel.toggleIngredientChecked(recipe: currentRecipe, ingredient: ingredient)
                        } label: {
                            HStack(alignment: .top) {
                                Image(systemName: viewModel.isIngredientChecked(recipe: currentRecipe, ingredient: ingredient) ? "checkmark.square.fill" : "square")
                                    .foregroundStyle(viewModel.isIngredientChecked(recipe: currentRecipe, ingredient: ingredient) ? .orange : .secondary)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(ingredient.name)
                                        .fontWeight(.medium)

                                    if !ingredient.measure.isEmpty {
                                        Text(ingredient.measure)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()
                            }
                            .foregroundStyle(.primary)
                            .padding(.vertical, 4)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Steps to cook it")
                        .font(.title2)
                        .fontWeight(.bold)

                    let steps = splitInstructions(currentRecipe.instructions)

                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .frame(width: 28, height: 28)
                                .background(.orange.opacity(0.18))
                                .clipShape(Circle())

                            Text(step)
                                .font(.body)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Recipe?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.deleteLocalRecipe(currentRecipe)
                dismiss()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This recipe will be removed from My Recipes and Favorites.")
        }
    }

    private func splitInstructions(_ text: String?) -> [String] {
        let cleanText = text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !cleanText.isEmpty else {
            return ["No instructions available."]
        }

        let lines = cleanText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if lines.count > 1 {
            return lines
        }

        return cleanText
            .components(separatedBy: ". ")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
