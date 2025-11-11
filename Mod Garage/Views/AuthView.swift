//
//  AuthView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 21/10/2025.
//

import SwiftUI

struct AuthView: View {
    @Binding var isUserLoggedIn: Bool
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Main auth content
                Group {
                    if viewModel.showLogin {
                        LoginView()
                    } else {
                        SignUpView()
                    }
                }

                // Toggle between login and sign up
                Button(action: viewModel.toggleView) {
                    HStack(spacing: 0) {
                        Text(viewModel.showLogin ? "Don't have an account? " : "Already have an account? ")
                            .font(.system(size: 14))
                            .foregroundColor(Color("bodyText"))

                        Text(viewModel.showLogin ? "Sign Up" : "Log In")
                            .foregroundColor(Color("redTheme"))
                            .fontWeight(.semibold)
                    }
                    .font(.footnote)
                    .padding(.top)
                }
            }
            .padding()
            .background(Color(.background))
        }
        .ignoresSafeArea(.keyboard)
        
    }
}

#Preview {
    AuthView(isUserLoggedIn: .constant(false))
}
