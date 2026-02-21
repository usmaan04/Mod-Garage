//
//  AuthViewModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 10/11/2025.
//

import Foundation
import Combine
import SwiftUI

enum AuthScreen {
    case login
    case signup
    case forgot
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentScreen: AuthScreen

    init(currentScreen: AuthScreen = .login) {
        self.currentScreen = currentScreen
    }

    func showLogin() {
        currentScreen = .login
    }

    func showSignup() {
        currentScreen = .signup
    }

    func showForgot() {
        currentScreen = .forgot
    }
}
