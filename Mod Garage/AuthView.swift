//
//  AuthView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 21/10/2025.
//

import SwiftUI

struct AuthView: View {
    // Binding to track if the user is logged in or not
    // State to toggle whether to show login or signup view
    @Binding var isUserLoggedIn: Bool
    @State private var showLogin = true

    var body: some View {
        // Main container for the authentication view
        NavigationStack {
            VStack(spacing: 20) {
                Text(showLogin ? "Welcome Back" : "Create Account")
                    .font(.largeTitle.bold())
                    .padding(.top, 20)

                // Show LoginView or SignUpView based on passed boolean
                if showLogin {
                    LoginView(isUserLoggedIn: $isUserLoggedIn)
                } else {
                    SignUpView(isUserLoggedIn: $isUserLoggedIn)
                }

                // Button to toggle between login and signup views
                Button(action: {
                    withAnimation {
                        showLogin.toggle()
                    }
                }) {
                    Text(showLogin ? "Don't have an account? Sign Up" : "Already have an account? Log In")
                        .foregroundColor(.blue)
                        .font(.footnote)
                        .padding(.top)
                }
            }
            .padding()
        }
    }
}

// Preview for Development
#Preview {
    AuthView(isUserLoggedIn: .constant(false))
}
