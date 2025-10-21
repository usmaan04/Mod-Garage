//
//  LoginView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 21/10/2025.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""

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

            Button(action: {
                print("Login tapped")
            }) {
                Text("Log In")
                    .frame(maxWidth: 250)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(30)
            }
            .padding(.top, 10)
        }
    }
}


#Preview {
    LoginView()
}
