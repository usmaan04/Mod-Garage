//
//  SplashScreenViewModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 10/11/2025.
//

import Combine
import Foundation
import FirebaseAuth

@MainActor
class SplashScreenViewModel: ObservableObject {
    // Keeps track of whether the Splash screen is still on screen
    @Published var isLoading = true
    
    // Keeps track of whether to send user to the Home or the Sign Up screen
    @Published var isAuthenticated = false
    
    // Check if user is authenticated
    func checkUserAuth() {
        // SAdd 2 second delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Check Firebase to see if there is a 'currentUser' saved
            self.isAuthenticated = Auth.auth().currentUser != nil
            
            // Once the check is done stop showing the splash screen
            self.isLoading = false
        }
    }
}
