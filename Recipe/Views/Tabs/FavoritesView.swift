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
                        FavoriteRecipeRow(recipe: recipe)
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Favorites")
    }
}

private struct FavoriteRecipeRow: View {
    @EnvironmentObject private var viewModel: AppViewModel

    let recipe: Recipe

    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .topTrailing) {
                RecipeImageView(recipe: recipe)
                    .frame(width: 92, height: 92)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                Button {
                    viewModel.toggleFavorite(recipe)
                } label: {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .padding(7)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .foregroundStyle(.red)
                }
                .padding(6)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.name)
                    .font(.headline)
                    .lineLimit(2)

                if let category = recipe.category, !category.isEmpty {
                    Text(category)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text("Tap heart to remove")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
