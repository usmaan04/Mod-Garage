//
//  SignUpView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 21/10/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift

struct SignUpView: View {
    var isOnboarding: Bool = false
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var viewModel = SignUpViewModel()
    
    var body: some View {
        VStack {
            
            Spacer()
            
            VStack(spacing: 6) {
                
                // Header
                Text("Welcome!")
                    .font(.system(size: 24, weight: .semibold))
                    .fontWidth(.condensed)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Prompt
                Text("Manage your rides, modifications, and MOT all in one place.")
                    .font(.system(size: 14))
                    .tracking(-0.4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.containerText)
                    .padding(.bottom, 10)
            }
            
            // Form Fields
            VStack(spacing: 24) {
                // Name label and field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                        .font(.system(size: 16).weight(.medium))
                        .fontWidth(.condensed)
                    TextField(
                        "",
                        text: $viewModel.name,
                        prompt: Text("Enter your name here...")
                            .foregroundStyle(Color.containerText)
                    )
                    .font(.system(size: 12))
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .padding(.vertical, 16)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.container)
                            .stroke(Color.containerBorder, lineWidth: 1)
                    )
                }
                
                // Email label and field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.system(size: 16).weight(.medium))
                        .fontWidth(.condensed)
                    TextField(
                        "",
                        text: $viewModel.email,
                        prompt: Text("Enter your email here...")
                            .foregroundStyle(Color.containerText)
                    )
                    .font(.system(size: 12))
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.vertical, 16)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.container)
                            .stroke(Color.containerBorder, lineWidth: 1)
                    )
                }
                
                // Password label and field
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text("Password")
                        .font(.system(size: 16).weight(.medium))
                        .fontWidth(.condensed)
                    
                    SecureField(
                        "",
                        text: $viewModel.password,
                        prompt: Text("••••••••")
                            .foregroundStyle(Color.containerText)
                    )
                    .font(.system(size: 12))
                    .padding(.vertical, 16)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.container)
                            .stroke(Color.containerBorder, lineWidth: 1)
                    )
                }
                
            }
            
            // Error message
            if let signUpError = viewModel.signUpError {
                Text(signUpError)
                    .font(.system(size: 14))
                    .tracking(-0.4)
                    .foregroundColor(.redTheme)
                    .padding(.top, 4)
                    .padding(.bottom, -6)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
            }
            
            // Sign Up Button
            Button(action: {
                Task {
                    await viewModel.register()
                    if viewModel.isUserLoggedIn {
                        if isOnboarding {
                            authVM.nextStep()
                        }
                    }
                }
            }) {
                Text("Sign Up")
                    .font(.system(size: 16).weight(.bold))
                    .fontWidth(.condensed)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.redTheme)
                    .foregroundColor(.white)
                    .cornerRadius(100)
            }
            .padding(.top, 12)
            .sensoryFeedback(.impact(weight: .medium, intensity: 1), trigger: viewModel.isLoading)
            
            // Divider with “Or”
            HStack {
                
                Divider()
                    .frame(maxWidth: .infinity, maxHeight: 1)
                    .background(Color.gray.opacity(0.4))
                
                Text("Or")
                    .font(.system(size: 14).weight(.medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 6)
                
                Divider()
                    .frame(maxWidth: .infinity, maxHeight: 1)
                    .background(Color.gray.opacity(0.4))
            }
            .padding(.vertical, 8)
            
            // MARK: - Google Sign Up Button
            Button(action: {
                Task{
                    await viewModel.signUpWithGoogle()
                    if viewModel.isUserLoggedIn {
                        if isOnboarding {
                            authVM.nextStep()
                        }
                    }
                }
            }) {
                HStack(spacing: 12) {
                    Image("google")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("Sign Up with Google")
                        .font(.system(size: 18).weight(.medium))
                        .fontWidth(.condensed)
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(
                    Color(UIColor { trait in
                        trait.userInterfaceStyle == .dark
                            ? .white
                        : .black
                    })
                )
                .padding()
                .background(
                    Color(UIColor { trait in
                        trait.userInterfaceStyle == .dark
                            ? .black
                        : .white
                    })
                )
                .cornerRadius(100)
            }
            .padding(.bottom, 12)
            
            Spacer()
        }
        .padding(.horizontal, 17)
        .background(Color.background)
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Notice"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .onChange(of: viewModel.isUserLoggedIn) { oldValue, newValue in
            if newValue && isOnboarding {
                authVM.nextStep()
            }
        }
    }
}

// Preview
#Preview {
    SignUpView()
}

