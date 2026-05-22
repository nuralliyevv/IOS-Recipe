//
//  AddRecipeView.swift
//  Recipe
//
//  Created by Мирас Нуралиев on 22.05.2026.
//

import SwiftUI
import PhotosUI

struct AddRecipeView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    @State private var recipeName = ""
    @State private var ingredientText = ""
    @State private var stepText = ""

    @State private var ingredients: [Ingredient] = []
    @State private var steps: [String] = []

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImageData: Data?

    @State private var showSavedMessage = false

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
                            VStack(spacing: 8) {
                                Image(systemName: "photo")
                                    .font(.largeTitle)

                                Text("Upload photo")
                                    .font(.headline)
                            }
                            .foregroundStyle(.secondary)
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
                            Spacer()
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
                        Text("\(index + 1). \(step)")
                            .padding(.vertical, 4)
                    }
                }

                Button {
                    saveRecipe()
                } label: {
                    Text("Save Recipe")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                if showSavedMessage {
                    Text("Recipe saved successfully.")
                        .foregroundStyle(.green)
                        .font(.footnote)
                }
            }
            .padding()
        }
        .navigationTitle("Add Recipe")
    }

    private func addIngredient() {
        let cleanIngredient = ingredientText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanIngredient.isEmpty else { return }

        ingredients.append(
            Ingredient(name: cleanIngredient, measure: "")
        )

        ingredientText = ""
    }

    private func addStep() {
        let cleanStep = stepText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanStep.isEmpty else { return }

        steps.append(cleanStep)
        stepText = ""
    }

    private func saveRecipe() {
        let cleanName = recipeName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanName.isEmpty else { return }

        let recipe = Recipe(
            id: UUID().uuidString,
            name: cleanName,
            imageURL: nil,
            category: "User Added",
            area: nil,
            instructions: steps.joined(separator: "\n\n"),
            ingredients: ingredients,
            localImageData: selectedImageData
        )

        viewModel.addLocalRecipe(recipe)

        recipeName = ""
        ingredientText = ""
        stepText = ""
        ingredients = []
        steps = []
        selectedPhoto = nil
        selectedImageData = nil
        showSavedMessage = true
    }
}
