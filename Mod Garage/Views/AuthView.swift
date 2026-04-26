//
//  AuthView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 21/10/2025.
//

import SwiftUI

struct AuthView: View {
    
    // Bindings to track if users logged in and/or onboarding
    @Binding var isUserLoggedIn: Bool
    @Binding var hasCompletedOnboarding: Bool
    
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        NavigationStack {
            Group {
                // If onboarding show onboard view
                if viewModel.currentScreen == .onboarding {
                    OnboardingView(authVM: viewModel)
                    
                // Otherwise show the relevant view based on the current screen
                } else {
                    VStack {
                        switch viewModel.currentScreen {
                        case .login:
                            LoginView()
                                .environmentObject(viewModel)
                        case .signup:
                            SignUpView()
                        case .forgot:
                            ForgotPasswordView()
                        case .onboarding:
                            EmptyView()
                        }

                        if viewModel.currentScreen != .onboarding{
                            authFooter
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .background(Color.background)
                }
            }
            .ignoresSafeArea(.keyboard)
        }
        .ignoresSafeArea(.keyboard)
        .toolbar(.hidden)
        .onTapGesture {
            hideKeyboard()
        }
    }

    // Simplified authentication footer to show button to switch pages
    @ViewBuilder
    private var authFooter: some View {
        switch viewModel.currentScreen {
        case .login:
            Button(action: viewModel.showSignup) {
                HStack(spacing: 4) {
                    Text("Don't have an account? ")
                        .font(.system(size: 14))
                        .foregroundColor(Color.containerText)

                    Text("SIGN UP")
                        .foregroundStyle(Color.redTheme)
                        .fontWeight(.semibold)
                        .fontWidth(.condensed)
                }
                .font(.footnote)
                .padding(.top)
            }

        case .signup:
            Button(action: viewModel.showLogin) {
                HStack(spacing: 4) {
                    Text("Already have an account? ")
                        .font(.system(size: 14))
                        .foregroundColor(Color.containerText)

                    Text("LOG IN")
                        .foregroundStyle(Color.redTheme)
                        .fontWeight(.semibold)
                        .fontWidth(.condensed)
                }
                .font(.footnote)
                .padding(.top)
            }

        case .forgot:
            Button(action: viewModel.showLogin) {
                HStack(spacing: 0) {
                    Text("Want to go back? ")
                        .font(.system(size: 14))
                        .foregroundColor(Color.containerText)

                    Text("GO BACK")
                        .foregroundStyle(Color.redTheme)
                        .fontWeight(.semibold)
                        .fontWidth(.condensed)
                }
                .font(.footnote)
                .padding(.top)
            }

        case .onboarding:
            EmptyView()
        }
    }
}

// Preview
#Preview {
    AuthView(
        isUserLoggedIn: .constant(false),
        hasCompletedOnboarding: .constant(false),
    )
}
