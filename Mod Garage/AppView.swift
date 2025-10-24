//
//  AppView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 23/10/2025.
//

import SwiftUI
import FirebaseAuth

struct AppView: View {
    // Tracks whether the user is currently logged in
    @State private var isUserLoggedIn = Auth.auth().currentUser != nil
    // Handle for Firebase auth state listener
    @State private var authStateListenerHandle: AuthStateDidChangeListenerHandle? = nil

    var body: some View {
        // Show relevant view based on login state
        Group {
            if isUserLoggedIn {
                MainAppView(isUserLoggedIn: $isUserLoggedIn)
                    .transition(.opacity)
            } else {
                // Show authentication view when logged out
                AuthView(isUserLoggedIn: $isUserLoggedIn)
                    .transition(.opacity)
            }
        }
        .onAppear {
            // Watch for login/logout changes in Firebase
            authStateListenerHandle = Auth.auth().addStateDidChangeListener { _, user in
                withAnimation {
                    isUserLoggedIn = (user != nil)
                }
            }
        }
        // Removes the Firebase auth listener to avoid leaks
        .onDisappear {
            if let handle = authStateListenerHandle {
                Auth.auth().removeStateDidChangeListener(handle)
                authStateListenerHandle = nil
            }
        }
    }
}
