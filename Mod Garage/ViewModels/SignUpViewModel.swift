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
    private func isPasswordValid(_ pass: String) -> Bool {
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

    //  Email & Password Registration
    func register() {
        signUpError = nil
        isLoading = true
        
        // Empty Field Validation
        if name.isEmpty || email.isEmpty || password.isEmpty{
            self.signUpError = "Please fill in all fields"
            self.isLoading = false
            return
        }
        
        // Email Validation
        if !isEmailValid(email){
            self.signUpError = "Please enter a valid email address"
            self.isLoading = false
            return
        }
        
        // Weak Password Validation
        if !isPasswordValid(password) {
            self.signUpError = "Password must include at least 8 characters, a number and a special character"
            self.isLoading = false
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let error = error as NSError? {
                DispatchQueue.main.async {
                    if let code = AuthErrorCode(rawValue: error.code) {
                        switch code {
                        case .emailAlreadyInUse:
                            self.signUpError = "This email is already registered"
                        case .networkError:
                            self.signUpError = "Network error. Check your internet connection."
                        default:
                            self.signUpError = error.localizedDescription
                        }
                    } else {
                        self.signUpError = "An unknown error occurred. Please try again."
                    }
                }
                return
            }

            guard let user = result?.user else {
                DispatchQueue.main.async {
                    self.signUpError = "User creation failed. Please try again."
                }
                return
            }

            DispatchQueue.main.async {
                self.isUserLoggedIn = true
            }
            self.saveUserDataToFirestore(userID: user.uid, name: self.name, email: self.email)
        }
    }

    // MARK: - Sign Up with Google
    func signUpWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            alertMessage = "Missing Google Client ID."
            showAlert = true
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Get the topmost ViewController to present Google sign-in UI
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            alertMessage = "Unable to find a valid window for Google Sign-In."
            showAlert = true
            return
        }

        isLoading = true

        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.signUpError = error.localizedDescription
                }
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.signUpError = "Google authentication failed. Please try again."
                }
                return
            }

            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            Auth.auth().signIn(with: credential) { authResult, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                }

                if let error = error {
                    DispatchQueue.main.async {
                        self.signUpError = error.localizedDescription
                    }
                    return
                }

                guard let firebaseUser = authResult?.user else { return }

                // Save user details to Firestore on the main actor to satisfy isolation
                Task { @MainActor in
                    self.saveUserDataToFirestore(
                        userID: firebaseUser.uid,
                        name: user.profile?.name ?? "User",
                        email: user.profile?.email ?? ""
                    )
                }
            }
        }
    }

    //  Firestore Helper
    private func saveUserDataToFirestore(userID: String, name: String, email: String) {
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "name": name,
            "email": email,
            "createdAt": Timestamp(date: Date())
        ]

        db.collection("users").document(userID).setData(userData) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.signUpError = "Failed to save user data: \(error.localizedDescription)"
                } else {
                    print("User data saved successfully for \(userID)")
                }
            }
        }
    }
}

