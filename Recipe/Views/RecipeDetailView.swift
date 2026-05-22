//
//  RecipeDetailView.swift
//  Recipe
//
//  Created by Мирас Нуралиев on 22.05.2026.
//

import SwiftUI

struct RecipeDetailView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    let recipe: Recipe

    @State private var ingredients: [Ingredient]

    init(recipe: Recipe) {
        self.recipe = recipe
        _ingredients = State(initialValue: recipe.ingredients)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                RecipeImageView(recipe: recipe)
                    .frame(height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .overlay(alignment: .topTrailing) {
                        Button {
                            viewModel.toggleFavorite(recipe)
                        } label: {
                            Image(systemName: viewModel.isFavorite(recipe) ? "heart.fill" : "heart")
                                .font(.title2)
                                .padding(10)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .foregroundStyle(viewModel.isFavorite(recipe) ? .red : .primary)
                        }
                        .padding()
                    }

                Text(recipe.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                HStack {
                    if let category = recipe.category, !category.isEmpty {
                        Label(category, systemImage: "tag")
                    }

                    if let area = recipe.area, !area.isEmpty {
                        Label(area, systemImage: "globe")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Ingredients")
                        .font(.title2)
                        .fontWeight(.bold)

                    ForEach($ingredients) { $ingredient in
                        Button {
                            ingredient.isChecked.toggle()
                        } label: {
                            HStack(alignment: .top) {
                                Image(systemName: ingredient.isChecked ? "checkmark.square.fill" : "square")
                                    .foregroundStyle(ingredient.isChecked ? .orange : .secondary)

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

                    let steps = splitInstructions(recipe.instructions)

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
