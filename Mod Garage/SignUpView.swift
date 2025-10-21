//
//  SignUpView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 21/10/2025.
//

import SwiftUI

struct SignUpView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""

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

            Button(action: {
                print("Sign Up tapped")
            }) {
                Text("Create Account")
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
    SignUpView()
}
