//
//  RecipeImageView.swift
//  Recipe
//
//  Created by Мирас Нуралиев on 22.05.2026.
//

import SwiftUI

struct RecipeImageView: View {
    let recipe: Recipe

    var body: some View {
        Group {
            if let localImageData = recipe.localImageData,
               let uiImage = UIImage(data: localImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else if let imageURL = recipe.imageURL,
                      let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Rectangle()
                                .fill(.gray.opacity(0.15))

                            ProgressView()
                        }

                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()

                    case .failure:
                        placeholder

                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .clipped()
    }

    private var placeholder: some View {
        ZStack {
            Rectangle()
                .fill(.gray.opacity(0.15))

            Image(systemName: "fork.knife")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
        }
    }
}
