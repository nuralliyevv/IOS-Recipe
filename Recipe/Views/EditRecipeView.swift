//
//  EditRecipeView.swift
//  Recipe
//
//  Created by Мирас Нуралиев on 23.05.2026.
//

import SwiftUI
import PhotosUI

struct EditRecipeView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    let originalRecipe: Recipe

    @State private var recipeName: String
    @State private var ingredientText = ""
    @State private var stepText = ""

    @State private var ingredients: [Ingredient]
    @State private var steps: [String]

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImageData: Data?

    init(recipe: Recipe) {
        self.originalRecipe = recipe

        _recipeName = State(initialValue: recipe.name)
        _ingredients = State(initialValue: recipe.ingredients)

        let existingSteps = recipe.instructions?
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty } ?? []

        _steps = State(initialValue: existingSteps.isEmpty ? [""] : existingSteps)
        _selectedImageData = State(initialValue: recipe.localImageData)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                TextField("Enter recipe name", text: $recipeName)
                    .padding()
                    .background(.gray.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(.gray.opacity(0.12))
                            .frame(height: 210)

                        if let selectedImageData,
                           let uiImage = UIImage(data: selectedImageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 210)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        } else {
                            RecipeImageView(recipe: originalRecipe)
                                .frame(height: 210)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .overlay {
                                    VStack(spacing: 8) {
                                        Image(systemName: "photo")
                                            .font(.largeTitle)

                                        Text("Tap to change photo")
                                            .font(.headline)
                                    }
                                    .foregroundStyle(.white)
                                    .padding()
                                    .background(.black.opacity(0.35))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                        }
                    }
                }
                .onChange(of: selectedPhoto) { newItem in
                    Task {
                        selectedImageData = try? await newItem?.loadTransferable(type: Data.self)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Ingredients")
                        .font(.headline)

                    HStack {
                        TextField("Enter ingredient", text: $ingredientText)
                            .padding()
                            .background(.gray.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 14))

                        Button {
                            addIngredient()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                    }

                    ForEach(ingredients) { ingredient in
                        HStack {
                            Image(systemName: "square")
                            Text(ingredient.name)

                            if !ingredient.measure.isEmpty {
                                Text("(\(ingredient.measure))")
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Button(role: .destructive) {
                                deleteIngredient(ingredient)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Steps to cook it")
                        .font(.headline)

                    HStack(alignment: .top) {
                        TextField("Enter cooking step", text: $stepText, axis: .vertical)
                            .lineLimit(2...4)
                            .padding()
                            .background(.gray.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 14))

                        Button {
                            addStep()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                        .padding(.top, 12)
                    }

                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top) {
                            Text("\(index + 1). \(step)")
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Button(role: .destructive) {
                                deleteStep(at: index)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Button {
                    saveChanges()
                } label: {
                    Text("Save Changes")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding()
        }
        .navigationTitle("Edit Recipe")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func addIngredient() {
        let cleanIngredient = ingredientText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanIngredient.isEmpty else { return }

        ingredients.append(
            Ingredient(name: cleanIngredient, measure: "")
        )

        ingredientText = ""
    }

    private func deleteIngredient(_ ingredient: Ingredient) {
        ingredients.removeAll { $0.id == ingredient.id }
    }

    private func addStep() {
        let cleanStep = stepText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanStep.isEmpty else { return }

        steps.append(cleanStep)
        stepText = ""
    }

    private func deleteStep(at index: Int) {
        guard steps.indices.contains(index) else { return }
        steps.remove(at: index)
    }

    private func saveChanges() {
        let cleanName = recipeName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanName.isEmpty else { return }

        let updatedRecipe = Recipe(
            id: originalRecipe.id,
            name: cleanName,
            imageURL: originalRecipe.imageURL,
            category: originalRecipe.category,
            area: originalRecipe.area,
            instructions: steps.joined(separator: "\n\n"),
            ingredients: ingredients,
            localImageData: selectedImageData
        )

        viewModel.updateLocalRecipe(updatedRecipe)
        dismiss()
    }
}
