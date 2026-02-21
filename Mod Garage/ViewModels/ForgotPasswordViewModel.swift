//
//  ForgotPasswordViewModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 20/02/2026.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

@MainActor
class ForgotPasswordViewModel: ObservableObject {
    // Published Properties (Bound to LoginView)
    @Published var email = ""
    @Published var errorMessage: String? = nil
    @Published var alertMessage: String? = nil
    @Published var isUserLoggedIn = false
    @Published var isLoading = false
    
    //Determine if email is valid
    private func isEmailValid(_ email: String) -> Bool {
        // Common regex pattern
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        // Create a predicate to test the email against the pattern
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailPattern)
        
        // Returns true only if condition is met
        return emailPredicate.evaluate(with: email)
    }
    
    func forgotPassword() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        // Basic validation
        guard !trimmedEmail.isEmpty else {
            self.errorMessage = "Please enter your email address"
            self.alertMessage = ""
            self.isLoading = false
            return
        }

        // Start loading
        self.isLoading = true
        self.errorMessage = nil
        self.alertMessage = ""

        Auth.auth().sendPasswordReset(withEmail: trimmedEmail) { [weak self] error in
            guard let self = self else { return }
            // Ensure updates happen on main actor since the class is @MainActor
            Task { @MainActor in
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.alertMessage = ""
                } else {
                    self.errorMessage = nil
                    self.alertMessage = "We sent a password reset link to \(trimmedEmail). Please check your inbox."
                }
            }
        }
    }

}
