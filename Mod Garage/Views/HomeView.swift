//
//  MainAppView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 23/10/2025.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    // Binding to track if the user is logged in or not
    @Binding var isUserLoggedIn: Bool

    // Function to log the user out
    func logout() {
        do {
            try Auth.auth().signOut()
            isUserLoggedIn = false
        } catch {
            print("Logout error:", error.localizedDescription)
        }
    }

    var body: some View {
        // Main container for home page
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome to Mod Garage!")
                    .font(.title)

                Button(action: logout) {
                    Text("Log Out")
                        .frame(maxWidth: 250)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
            }
            .navigationTitle("Home")
        }
    }
}

