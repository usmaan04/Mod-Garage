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

// Handles logic for the forgot password view/flow
@MainActor
class ForgotPasswordViewModel: ObservableObject {
    
    // UI states
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
    
    // Validates user entered/enterable fields
    func isFormValid() -> Bool {
        // Reset previous error
        errorMessage = nil

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        // Empty email
        if trimmedEmail.isEmpty {
            errorMessage = "Please enter your email address"
            return false
        }

        // Email format
        if !isEmailValid(trimmedEmail) {
            errorMessage = "Please enter a valid email address"
            return false
        }

        return true
    }
    
    func forgotPassword() {
        // Validate form
        guard isFormValid() else {
            self.isLoading = false
            self.alertMessage = nil
            return
        }

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        // Start loading
        self.isLoading = true
        self.errorMessage = nil
        self.alertMessage = nil

        // Send password reset email
        Auth.auth().sendPasswordReset(withEmail: trimmedEmail) { [weak self] error in
            guard let self = self else { return }
            // Ensure updates happen on main actor since the class is @MainActor
            Task { @MainActor in
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.alertMessage = nil
                } else {
                    self.errorMessage = nil
                    self.alertMessage = "If an account exists an email has been sent to \(trimmedEmail)"
                }
            }
        }
    }

}
