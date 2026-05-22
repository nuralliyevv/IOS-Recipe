//
//  ProfileView.swift
//  Recipe
//
//  Created by Мирас Нуралиев on 22.05.2026.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 86))
                .foregroundStyle(.orange)
                .padding(.top, 40)

            VStack(spacing: 8) {
                Text("Signed in user")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text(viewModel.signedInUser?.email ?? "No email")
                    .font(.title3)
                    .fontWeight(.semibold)
            }

            VStack(spacing: 10) {
                ProfileInfoRow(title: "Favorite recipes", value: "\(viewModel.favoriteRecipes.count)")
                ProfileInfoRow(title: "Added recipes", value: "\(viewModel.addedRecipes.count)")
            }
            .padding()
            .background(.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .padding(.horizontal)

            Button(role: .destructive) {
                viewModel.signOut()
            } label: {
                Text("Sign Out")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.red.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("Profile")
    }
}

private struct ProfileInfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)

            Spacer()

            Text(value)
                .fontWeight(.semibold)
        }
    }
}
