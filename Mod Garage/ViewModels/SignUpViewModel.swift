//
//  SignUpViewModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 11/11/2025.
//

import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import GoogleSignIn
import UIKit

@MainActor
class SignUpViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var signUpError: String? = nil
    @Published var showAlert = false
    @Published var alertMessage = ""
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

    
    // Determine if password is strong enough
    func isPasswordValid(_ pass: String) -> Bool {
        // Check 8 char length
        if pass.count < 8 {
            return false
        }
        
        // Check for a number
        let hasNumber = pass.contains { $0.isNumber }
        
        // Check for a special character
        let specialCharSet = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{};:'\\|,.<>/?")
        let hasSpecialChar = pass.rangeOfCharacter(from: specialCharSet) != nil
        
        // Return true only if all conditions are met
        return hasNumber && hasSpecialChar
    }
    
    // Centralized form validation: sets signUpError and returns validity
    @discardableResult
    func isFormValid() -> Bool {
        // Reset previous error
        signUpError = nil

        // Empty fields
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            password.isEmpty {
            signUpError = "Please fill in all fields"
            return false
        }

        // Email format
        if !isEmailValid(email) {
            signUpError = "Please enter a valid email address"
            return false
        }

        // Password strength
        if !isPasswordValid(password) {
            signUpError = "Password must include at least 8 characters, a number and a special character"
            return false
        }

        return true
    }

    //  Email & Password Registration
    func register() async {
        signUpError = nil
        isLoading = true
        
        // Validate all fields
        if !isFormValid() {
            self.isLoading = false
            return
        }

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do{
            let result = try await Auth.auth().createUser(withEmail: trimmedEmail, password: trimmedPassword)
            
            try await saveUserDataToFirestore(userID: result.user.uid, name: name, email: trimmedEmail)
            
            self.isUserLoggedIn = true
            self.isLoading = false
        }catch let error as NSError {
            self.isLoading = false
            
            let nsError = error as NSError
            
            if nsError.domain == AuthErrorDomain {
              
                if let errorCode = AuthErrorCode(rawValue: nsError.code) {
                    switch errorCode {
                    case .emailAlreadyInUse:
                        self.signUpError = "This email is already registered"
                    case .networkError:
                        self.signUpError = "Network error, please check your connection"
                    case .weakPassword:
                        self.signUpError = "Password is too weak."
                    case .invalidEmail:
                        self.signUpError = "Invalid email address format"
                    default:
                        self.signUpError = nsError.localizedDescription
                    }
                } else {
                    self.signUpError = nsError.localizedDescription
                }
            } else {
               
                self.signUpError = error.localizedDescription
            }
        }

    }

    // MARK: - Sign Up with Google
    func signUpWithGoogle() async {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            alertMessage = "Missing Google Client ID."
            showAlert = true
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            alertMessage = "Unable to find a valid window for Google Sign-In."
            showAlert = true
            return
        }

        isLoading = true
        signUpError = nil

        do {
            let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<GIDSignInResult, Error>) in
                GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let result = result {
                        continuation.resume(returning: result)
                    } else {
                        continuation.resume(throwing: NSError(
                            domain: "GoogleSignIn",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Google authentication failed."]
                        ))
                    }
                }
            }

            let user = result.user

            guard let idToken = user.idToken?.tokenString else {
                throw NSError(
                    domain: "GoogleSignIn",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "Missing Google ID token."]
                )
            }

            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            let authResult = try await Auth.auth().signIn(with: credential)

            try await saveUserDataToFirestore(
                userID: authResult.user.uid,
                name: user.profile?.name ?? "User",
                email: user.profile?.email ?? ""
            )

            isUserLoggedIn = true
        } catch {
            signUpError = error.localizedDescription
        }

        isLoading = false
    }
    
    //  Firestore Helper
    private func saveUserDataToFirestore(userID: String, name: String, email: String) async throws {
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "name": name,
            "email": email,
            "createdAt": Timestamp(date: Date())
        ]
        
        try await db.collection("users").document(userID).setData(userData)
    }
}

