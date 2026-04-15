//
//  AuthViewModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 10/11/2025.
//

import Foundation
import Combine
import SwiftUI

// Enumeration to represent the different authentication screens
enum AuthScreen {
    case login
    case signup
    case forgot
    case onboarding
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentScreen: AuthScreen
    
    // Persistent flag stored on the device
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
        
    // Tracks the current step of onboarding
    @Published var currentStep: Int = 0
    
    init() {
        if !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
            // If they haven't finished onboarding, send them there first
            self.currentScreen = .onboarding
        } else {
            // Otherwise, start them on the regular sign up page
            self.currentScreen = .signup
        }
    }
    func nextStep() {
        withAnimation {
            currentStep += 1
        }
    }
    
    // ompletes onborading
    func finishOnboarding() {
        withAnimation {
            hasCompletedOnboarding = true
        }
    }

    // Helper function to switch the UI to the Login screen
    func showLogin() {
        currentScreen = .login
    }

    // Helper function to switch the UI to the Sign Up screen
    func showSignup() {
        currentScreen = .signup
    }

    // Helper function to switch the UI to the Forgot Password screen
    func showForgot() {
        currentScreen = .forgot
    }
    
    func showOnboarding() {
        currentScreen = .onboarding
    }
}
