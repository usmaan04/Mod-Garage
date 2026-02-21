//
//  LoginViewModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 11/11/2025.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

@MainActor
class LoginViewModel: ObservableObject {
    // Published Properties (Bound to LoginView)
    @Published var email = ""
    @Published var forgotEmail = ""
    @Published var password = ""
    @Published var loginError: String? = nil
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isPasswordVisible = false
    @Published var isUserLoggedIn = false
    @Published var isLoading = false
    
    // Email/Password Login
    func login() {
        
        if email.isEmpty || password.isEmpty{
            self.loginError = "Please fill in all fields"
            self.isLoading = false
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.loginError = self.handleFirebaseError(error)
                return
            }
            
            // Login success
            self.isUserLoggedIn = true
        }
    }
    
    // MARK: - Google Sign-In
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            alertMessage = "Missing Google Client ID."
            showAlert = true
            return
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            alertMessage = "Unable to find a valid window for Google Sign-In."
            showAlert = true
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            if let error = error {
                Task { @MainActor in
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                }
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                Task { @MainActor in
                    self.alertMessage = "Google authentication failed."
                    self.showAlert = true
                }
                return
            }

            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    Task { @MainActor in
                        self.alertMessage = error.localizedDescription
                        self.showAlert = true
                    }
                    return
                }
                Task { @MainActor in
                    self.isUserLoggedIn = true
                }
            }
        }
    }

    // Firebase Error Handling
    private func handleFirebaseError(_ error: Error) -> String {
        let nsError = error as NSError
        guard let code = AuthErrorCode(rawValue: nsError.code) else {
            return nsError.localizedDescription
        }

        switch code {
        case .invalidEmail, .userNotFound, .wrongPassword, .invalidCredential:
            return "Invalid email or password. If you registered with Google, try the Google button below."
        case .userDisabled:
            return "This account has been disabled."
        case .networkError:
            return "Network error. Please check your connection."
        default:
            return nsError.localizedDescription
        }
    }
}
