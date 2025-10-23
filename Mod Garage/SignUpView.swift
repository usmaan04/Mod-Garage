//
//  SignUpView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 21/10/2025.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct SignUpView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isUserLoggedIn = false
    
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            // Successfully created account; present the main app UI
            isUserLoggedIn = true
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Image("AdaptiveLaunch")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)

            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button {
                register() 
            } label: {
                Text("Create Account")
                    .frame(maxWidth: 250)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(30)
            }
            .padding(.top, 10)
        }
        .fullScreenCover(isPresented: $isUserLoggedIn) {
            MainAppView()
        }
    }
}


#Preview {
    SignUpView()
}
