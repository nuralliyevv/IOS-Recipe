//
//  RootView.swift
//  Recipe
//
//  Created by Мирас Нуралиев on 22.05.2026.
//

import SwiftUI

struct RootView: View {
    @StateObject private var viewModel = AppViewModel()

    var body: some View {
        Group {
            if viewModel.isSignedIn {
                MainTabView()
                    .environmentObject(viewModel)
            } else {
                NavigationStack {
                    SignInView()
                        .environmentObject(viewModel)
                }
            }
        }
    }
}

#Preview {
    RootView()
}
