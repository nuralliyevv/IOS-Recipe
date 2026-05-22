//
//  SearchView.swift
//  Recipe
//
//  Created by Мирас Нуралиев on 22.05.2026.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    @State private var searchText = ""
    @State private var searchTask: Task<Void, Never>?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)

                    TextField("Search recipes", text: $searchText)
                        .textInputAutocapitalization(.never)
                }
                .padding(12)
                .background(.gray.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                Button("Cancel") {
                    searchTask?.cancel()
                    searchText = ""
                    viewModel.searchResults = []

                    Task {
                        await viewModel.loadRecommendations(forceReload: true)
                    }
                }
            }
            .padding()

            if viewModel.isSearching {
                ProgressView("Searching...")
                    .padding(.top, 40)

                Spacer()
            } else {
                List(viewModel.searchResults) { recipe in
                    NavigationLink {
                        RecipeDetailView(recipe: recipe)
                    } label: {
                        HorizontalRecipeRow(recipe: recipe)
                    }
                    .swipeActions {
                        Button {
                            viewModel.toggleFavorite(recipe)
                        } label: {
                            Label(
                                viewModel.isFavorite(recipe) ? "Remove" : "Favorite",
                                systemImage: viewModel.isFavorite(recipe) ? "heart.slash" : "heart"
                            )
                        }
                        .tint(.orange)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Search")
        .task {
            await viewModel.loadRecommendations()
        }
        .onChange(of: searchText) { newValue in
            searchTask?.cancel()

            searchTask = Task {
                try? await Task.sleep(nanoseconds: 350_000_000)

                if Task.isCancelled {
                    return
                }

                await viewModel.searchRecipes(query: newValue)
            }
        }
    }
}
