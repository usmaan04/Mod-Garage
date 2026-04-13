//
//  LoginView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 21/10/2025.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                VStack(spacing: 6){
                    // Title
                    Text("Welcome Back!")
                        .font(.system(size: 24, weight: .semibold))
                        .fontWidth(.condensed)
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .foregroundColor(.lightBlack)
                    // Title
                    Text("Manage your rides, modifications, and MOT all in one place.")
                        .font(.system(size: 14))
                        .tracking(-0.4)
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .foregroundColor(.bodyText)
                        .padding(.bottom, 10)
                }
                VStack(spacing:24){
                    // Email Label and Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.system(size: 16).weight(.medium))
                            .fontWidth(.condensed)
                        TextField(
                                "",
                                text: $viewModel.email,
                                prompt: Text("Enter your email here...")
                                    .foregroundColor(Color("bodyText"))
                            )
                            .font(.system(size: 12))
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.boxbackground)
                                    .stroke(Color.rectBorder, lineWidth: 1)
                            )
                    }
                    
                    // Password Label and Field
                    VStack(alignment: .leading, spacing: 8) {
                        HStack{
                            Text("Password")
                                .font(.system(size: 16).weight(.medium))
                                .fontWidth(.condensed)
                            // Forgot Password
                            Button {
                                authViewModel.showForgot()
                            } label: {
                                HStack(spacing: 6) {
                                    Text("Forgot password?")
                                        .foregroundStyle(Color.redTheme)
                                        .font(.system(size: 15).weight(.semibold))
                                        .fontWidth(.condensed)
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                            .scaleEffect(0.8)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .buttonStyle(.plain)
                            
                        }
                        HStack {
                            if viewModel.isPasswordVisible {
                                TextField(
                                    "",
                                    text: $viewModel.password,
                                    prompt: Text("••••••••")
                                        .foregroundColor(.bodyText)
                                )
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .keyboardType(.asciiCapable)
                                .font(.system(size: 12))
                            } else {
                                SecureField(
                                    "",
                                    text: $viewModel.password,
                                    prompt: Text("••••••••")
                                        .foregroundColor(.bodyText)
                                )
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .keyboardType(.asciiCapable)
                                .font(.system(size: 12))
                            }

                            Button(action: {
                                viewModel.isPasswordVisible.toggle()
                            }) {
                                Image(systemName: viewModel.isPasswordVisible ? "eye" : "eye.slash")
                                    .foregroundColor(.gray)
                            }
                            .buttonStyle(.plain)
                            .contentShape(Rectangle())
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.boxbackground)
                                .stroke(Color.rectBorder, lineWidth: 1)
                        )
                    }
                }
                
                // Error Message
                if let loginError = viewModel.loginError {
                    Text(loginError)
                        .font(.system(size: 14))
                        .tracking(-0.4)
                        .foregroundColor(.redTheme)
                        .padding(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Login Button
                Button(action: {
                    viewModel.login()
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.redTheme)
                            .cornerRadius(100)
                    } else {
                        Text("Log In")
                            .font(.system(size: 16).weight(.bold))
                            .fontWidth(.condensed)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.redTheme)
                            .foregroundColor(.white)
                            .cornerRadius(100)
                    }
                }
                .padding(.top, 2)
                
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
                
                // Google Sign-In Button
                Button(action: {
                    viewModel.signInWithGoogle()
                }) {
                    HStack(spacing: 12) {
                        Image("google")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Continue with Google")
                            .font(.system(size: 18).weight(.medium))
                            .fontWidth(.condensed)
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
            .padding(.horizontal, 17)
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Notice"),
                    message: Text(viewModel.alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    LoginView()
}
