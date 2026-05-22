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

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)

                    TextField("Search recipes", text: $searchText)
                        .textInputAutocapitalization(.never)
                        .onSubmit {
                            Task {
                                await viewModel.searchRecipes(query: searchText)
                            }
                        }
                }
                .padding(12)
                .background(.gray.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                Button("Cancel") {
                    searchText = ""
                    viewModel.searchResults = []

                    Task {
                        await viewModel.loadRecommendations()
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
                            Label("Favorite", systemImage: "heart")
                        }
                        .tint(.orange)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Search")
        .toolbar {
            Button("Search") {
                Task {
                    await viewModel.searchRecipes(query: searchText)
                }
            }
        }
        .task {
            await viewModel.loadRecommendations()
        }
    }
}
