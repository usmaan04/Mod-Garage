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
                    switch viewModel.currentScreen {
                    case .login:
                        LoginView()
                            .environmentObject(viewModel)
                    case .signup:
                        SignUpView()
                    case .forgot:
                        ForgotPasswordView()
                    }
                }
                
                switch viewModel.currentScreen {
                case .login:
                    Button(action: viewModel.showSignup) {
                        HStack(spacing: 0) {
                            Text("Don't have an account? ")
                                .font(.system(size: 14))
                                .foregroundColor(Color("bodyText"))

                            Text("Sign Up")
                                .foregroundStyle(Color.redTheme)
                                .fontWeight(.semibold)
                        }
                        .font(.footnote)
                        .padding(.top)
                    }
                case .signup:
                    Button(action: viewModel.showLogin) {
                        HStack(spacing: 0) {
                            Text("Already have an account? ")
                                .font(.system(size: 14))
                                .foregroundColor(Color("bodyText"))

                            Text("Log In")
                                .foregroundStyle(Color.redTheme)
                                .fontWeight(.semibold)
                        }
                        .font(.footnote)
                        .padding(.top)
                    }
                case .forgot:
                    Button(action: viewModel.showLogin) {
                        HStack(spacing: 0) {
                            Text("Want to go back? ")
                                .font(.system(size: 14))
                                .foregroundColor(Color("bodyText"))

                            Text("Log In")
                                .foregroundStyle(Color.redTheme)
                                .fontWeight(.semibold)
                        }
                        .font(.footnote)
                        .padding(.top)
                    }
                }
            }
            .padding()
            .background(Color.background)
            .ignoresSafeArea(.keyboard)
        }
        .ignoresSafeArea(.keyboard)
        
    }
}

#Preview {
    AuthView(isUserLoggedIn: .constant(false))
}
