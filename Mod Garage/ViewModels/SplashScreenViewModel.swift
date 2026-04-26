//
//  SplashScreenViewModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 10/11/2025.
//

import Combine
import Foundation
import FirebaseAuth
@preconcurrency import UserNotifications

@MainActor
class SplashScreenViewModel: ObservableObject {
    // Keeps track of whether the Splash screen is still on screen
    @Published var isLoading = true
    
    // Determines whether to send user to the Home or the Sign Up screen
    @Published var isAuthenticated = false
    
    // Check if user is authenticated
    func checkUserAuth() {
        // Add 2 second delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Check Firebase to see if there's a user saved
            self.isAuthenticated = Auth.auth().currentUser != nil
            
            // Once the check is done stop showing the splash screen
            self.isLoading = false
        }
    }
    
    // Request notification permission from the user
    func requestNotificationPermission(completion: @escaping () -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            default:
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
}
