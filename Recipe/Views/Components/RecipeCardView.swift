//
//  RecipeCardView.swift
//  Recipe
//
//  Created by Мирас Нуралиев on 22.05.2026.
//

import SwiftUI

struct RecipeCardView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RecipeImageView(recipe: recipe)
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(alignment: .topTrailing) {
                    Button {
                        viewModel.toggleFavorite(recipe)
                    } label: {
                        Image(systemName: viewModel.isFavorite(recipe) ? "heart.fill" : "heart")
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .foregroundStyle(viewModel.isFavorite(recipe) ? .red : .primary)
                    }
                    .padding(8)
                }

            Text(recipe.name)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            if let category = recipe.category, !category.isEmpty {
                Text(category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(.gray.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
