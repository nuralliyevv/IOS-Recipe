//
//  SignInView.swift
//  Recipe
//
//  Created by Мирас Нуралиев on 22.05.2026.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Text("Welcome")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Sign in to continue")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 14) {
                TextField("Enter email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(.gray.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                SecureField("Enter password", text: $password)
                    .padding()
                    .background(.gray.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Button {
                viewModel.signIn(email: email, password: password)
            } label: {
                Text("Sign In")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.orange)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Spacer()

            HStack(spacing: 4) {
                Text("Don't have an account?")
                    .foregroundStyle(.secondary)

                NavigationLink("Sign up") {
                    SignUpView()
                        .environmentObject(viewModel)
                }
                .fontWeight(.semibold)
            }
            .padding(.bottom)
        }
        .padding()
    }
}
