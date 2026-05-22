//
//  FavoritesView.swift
//  Recipe
//
//  Created by Мирас Нуралиев on 22.05.2026.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    @State private var selectedSection: FavoritesSection = .favorites

    var body: some View {
        VStack(spacing: 0) {
            sectionPicker

            Divider()

            Group {
                switch selectedSection {
                case .favorites:
                    favoritesList

                case .myRecipes:
                    myRecipesList
                }
            }
        }
        .navigationTitle("Favorites")
    }

    private var sectionPicker: some View {
        HStack(spacing: 12) {
            sectionButton(title: "Favorites", section: .favorites)
            sectionButton(title: "My Recipes", section: .myRecipes)
        }
        .padding()
    }

    private func sectionButton(title: String, section: FavoritesSection) -> some View {
        Button {
            selectedSection = section
        } label: {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selectedSection == section ? .orange : .gray.opacity(0.12))
                .foregroundStyle(selectedSection == section ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private var favoritesList: some View {
        Group {
            if viewModel.favoriteRecipes.isEmpty {
                EmptyStateView(
                    icon: "heart",
                    title: "No Favorites Yet",
                    message: "Tap the heart button on a recipe to add it here."
                )
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
    }

    private var myRecipesList: some View {
        Group {
            if viewModel.addedRecipes.isEmpty {
                EmptyStateView(
                    icon: "book.closed",
                    title: "No Recipes Added Yet",
                    message: "Go to the Add tab to create your own recipe."
                )
            } else {
                List(viewModel.addedRecipes) { recipe in
                    NavigationLink {
                        RecipeDetailView(recipe: recipe)
                    } label: {
                        HorizontalRecipeRow(recipe: recipe)
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

private enum FavoritesSection {
    case favorites
    case myRecipes
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

private struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.title2)
                .fontWeight(.bold)

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        FavoritesView()
            .environmentObject(AppViewModel())
    }
}
