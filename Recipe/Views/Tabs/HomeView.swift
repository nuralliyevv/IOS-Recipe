//
//  HomeView.swift
//  Recipe
//
//  Created by Мирас Нуралиев on 22.05.2026.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            if viewModel.isLoadingHome {
                ProgressView("Loading recipes...")
                    .padding(.top, 80)
            } else {
                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(viewModel.homeRecipes) { recipe in
                        NavigationLink {
                            RecipeDetailView(recipe: recipe)
                        } label: {
                            RecipeCardView(recipe: recipe)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Recipes")
        .task {
            await viewModel.loadHomeRecipes()
        }
        .refreshable {
            await viewModel.reloadHomeRecipes()
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(AppViewModel())
    }
}
