//
//  LoginView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 21/10/2025.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    // Binding to track if the user is logged in or not
    @Binding var isUserLoggedIn: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var loginError: String? = nil

    func login() {
        loginError = nil
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                if let code = AuthErrorCode(rawValue: error.code) {
                    switch code {
                        case .invalidEmail, .userNotFound, .wrongPassword, .invalidCredential:
                            loginError = "Username or password is incorrect, Please try again."
                        case .userDisabled:
                            loginError = "This account has been disabled."
                        case .networkError:
                            loginError = "Network error. Please check your connection."
                        default:
                            loginError = error.localizedDescription
                    }
                } else {
                    loginError = error.localizedDescription
                }
                return
            }
            // Success
            isUserLoggedIn = true
        }
    }

    var body: some View {
        // Main container for the Login view
        VStack(spacing: 16) {
            // Logo
            Image("AdaptiveLaunch")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)

            // Email field
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            // Password field
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Password error text
            if let loginError = loginError {
                Text(loginError)
                    .font(.callout)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Login button
            Button(action: login) {
                Text("Log In")
                    .frame(maxWidth: 250)
                    .padding()
                    .background(isFormValid ? Color.red : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(30)
            }
            .padding(.top, 10)
            .disabled(!isFormValid)
        }
        .padding()
    }
    // Determine if full form is valid
    var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
}

// Preview for Development
#Preview {
    LoginView(isUserLoggedIn: .constant(false))
}
