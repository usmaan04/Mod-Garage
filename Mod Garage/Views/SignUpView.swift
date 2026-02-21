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
    @StateObject private var viewModel = SignUpViewModel()
    
    var body: some View {
        VStack {
            Spacer()
            
            // - Header
            VStack(spacing: 6) {
                Text("Welcome!")
                    .font(.system(size: 22, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.lightBlack)
                
                Text("Manage your rides, modifications, and MOT all in one place.")
                    .font(.system(size: 14))
                    .tracking(-0.4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.bodyText)
                    .padding(.bottom, 10)
            }
            
            //  Form Fields
            VStack(spacing: 24) {
                // Name Label and Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                        .font(.system(size: 14).weight(.medium))
                    TextField(
                        "",
                        text: $viewModel.name,
                        prompt: Text("Enter your name here...")
                            .foregroundColor(Color("bodyText"))
                    )
                    .font(.system(size: 12))
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .padding(.vertical, 16)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.boxbackground)
                            .stroke(Color.rectBorder, lineWidth: 1)
                    )
                }
                
                // Email Label and Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.system(size: 14).weight(.medium))
                    TextField(
                        "",
                        text: $viewModel.email,
                        prompt: Text("Enter your email here...")
                            .foregroundColor(Color("bodyText"))
                    )
                    .font(.system(size: 12))
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.vertical, 16)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.boxbackground)
                            .stroke(Color.rectBorder, lineWidth: 1)
                    )
                }
                
                // Password Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.system(size: 14).weight(.medium))
                    SecureField(
                        "",
                        text: $viewModel.password,
                        prompt: Text("••••••••")
                            .foregroundColor(Color("bodyText"))
                    )
                    .font(.system(size: 12))
                    .padding(.vertical, 16)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.boxbackground)
                            .stroke(Color.rectBorder, lineWidth: 1)
                    )
                }
                
            }
            
            // Validation Errors
            if let signUpError = viewModel.signUpError {
                Text(signUpError)
                    .font(.callout)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            //  Create Account Button
            Button(action: {
                viewModel.register()
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.redTheme)
                        .cornerRadius(100)
                } else {
                    Text("Sign Up")
                        .font(.system(size: 14).weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.redTheme)
                        .foregroundColor(.white)
                        .cornerRadius(100)
                }
            }
            .padding(.top, 12)
            
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
            
            // MARK: - Google Sign-In Button
            Button(action: {
                viewModel.signUpWithGoogle()
            }) {
                HStack(spacing: 12) {
                    Image("google")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("Sign in with Google")
                        .font(.system(size: 16).weight(.medium))
                        .foregroundColor(.lightBlack)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    Color(UIColor { trait in
                        trait.userInterfaceStyle == .dark
                            ? .black
                        : .backgroundW
                    })
                )
                .cornerRadius(100)
            }
            .padding(.bottom, 12)
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .background(Color.background)
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Notice"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

// Preview
#Preview {
    SignUpView()
}

