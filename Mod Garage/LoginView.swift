//
//  LoginView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 21/10/2025.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isUserLoggedIn = false
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            // Successfully signed in; present the main app UI
            isUserLoggedIn = true
        }
    }
    

    var body: some View {
        VStack(spacing: 16) {
            Image("AdaptiveLaunch")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button{
                login()
            } label: {
                Text("Log In")
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
    LoginView()
}
