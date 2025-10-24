//
//  SignUpView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 21/10/2025.
//

//
//  SignUpView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 21/10/2025.
//

import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    // Binding to track if the user is logged in or not
    @Binding var isUserLoggedIn: Bool

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""

    // Validation state for email and password
    @State private var isEmailValid: Bool = true
    @State private var emailError: String? = nil
    @State private var isPasswordValid: Bool = true
    @State private var passwordError: String? = nil
    @State private var signUpError: String? = nil

    // Alert for backend / signup errors
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 16) {
            // Logo
            Image("AdaptiveLaunch")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)

            // Name field
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            // Email field
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .onChange(of: email) {
                    validateEmail(email)
                }

            // Password field
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: password) {
                    validatePassword(password)
                }
            
            // Email error text
            if let emailError = emailError {
                Text(emailError)
                    .font(.callout)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Password error text
            if let passwordError = passwordError {
                Text(passwordError)
                    .font(.callout)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Register button (disabled until validation is passed)
            Button(action: register) {
                Text("Create Account")
                    .frame(maxWidth: 250)
                    .padding()
                    .background(isFormValid ? Color.red : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(30)
            }
            .disabled(!isFormValid)
            .padding(.top, 10)
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Signup Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    // Determine if full form is valid
    var isFormValid: Bool {
        return isEmailValid && isPasswordValid && !email.isEmpty && !password.isEmpty
    }
    
    // Validate email with regex
    func textFieldValidatorEmail(_ string: String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: string)
    }

    // Validate email function
    func validateEmail(_ string: String) {
        if string.isEmpty {
            isEmailValid = false
            emailError = "Email cannot be empty"
            return
        }
        let valid = textFieldValidatorEmail(string)
        isEmailValid = valid
        emailError = valid ? nil : "Email must contain @ and a domain"
    }

    // Validate password function
    func validatePassword(_ string: String) {
        if string.isEmpty {
            isPasswordValid = false
            passwordError = "Password cannot be empty"
            return
        }

        // min 8 characters, one digit and one special character
        let passwordPattern = "^(?=.*[0-9])(?=.*[!@#$%^&*])[A-Za-z0-9!@#$%^&*]{8,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", passwordPattern)
        let valid = predicate.evaluate(with: string)
        isPasswordValid = valid
        passwordError = valid ? nil : "Password must be at least 8 characters and include a number and a special character"
    }

    // Register function
    func register() {
        // Re-run validations to be safe
        validateEmail(email)
        validatePassword(password)

        guard isFormValid else {
            // Shouldn't happen if button is disabled
            alertMessage = "Please fix form errors before continuing."
            showAlert = true
            return
        }

        // Create user in Firebase
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                if let code = AuthErrorCode(rawValue: error.code) {
                    if code == .emailAlreadyInUse{
                        signUpError = "This email is already in use please try another email"
                    }
                }else {
                        signUpError = error.localizedDescription
                    }
                    return
                }
                // Success
                isUserLoggedIn = true
            }
    }
}

// Preview for Development
#Preview {
    SignUpView(isUserLoggedIn: .constant(false))
}
