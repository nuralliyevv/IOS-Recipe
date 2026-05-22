//
//  FavoritesView.swift
//  Recipe
//
//  Created by Мирас Нуралиев on 22.05.2026.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    var body: some View {
        Group {
            if viewModel.favoriteRecipes.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "heart")
                        .font(.system(size: 56))
                        .foregroundStyle(.secondary)

                    Text("No Favorites Yet")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Tap the heart button on a recipe to add it here.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            } else {
                List(viewModel.favoriteRecipes) { recipe in
                    NavigationLink {
                        RecipeDetailView(recipe: recipe)
                    } label: {
                        HorizontalRecipeRow(recipe: recipe)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Favorites")
    }
}
