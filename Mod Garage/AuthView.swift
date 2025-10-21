//
//  AuthView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 21/10/2025.
//

import SwiftUI

struct AuthView: View {
    @State private var showLogin = true

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(showLogin ? "Welcome Back" : "Create Account")
                    .font(.largeTitle.bold())
                    .padding(.top, 40)

                if showLogin {
                    LoginView()
                } else {
                    SignUpView()
                }

                Button(action: {
                    withAnimation {
                        showLogin.toggle()
                    }
                }) {
                    Text(showLogin ? "Don't have an account? Sign Up" : "Already have an account? Log In")
                        .foregroundColor(.blue)
                        .font(.footnote)
                        .padding(.top)
                }
            }
            .padding()
        }
    }
}


#Preview {
    AuthView()
}
