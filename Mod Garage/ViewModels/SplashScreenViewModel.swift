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
    @Published var isLoading = true
    @Published var isAuthenticated = false
    
    // Check if user is authenticated
    func checkUserAuth() {
        // Simulate loading animation delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isAuthenticated = Auth.auth().currentUser != nil
            self.isLoading = false
        }
    }
}
