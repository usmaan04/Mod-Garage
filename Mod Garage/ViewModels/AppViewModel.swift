//
//  AppViewModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 10/11/2025.
//

import Foundation
import Combine
import SwiftUI
import FirebaseAuth

@MainActor
final class AppViewModel: ObservableObject {
    @Published var isUserLoggedIn: Bool = Auth.auth().currentUser != nil
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        listenToAuthChanges()
    }

    // ✅ Swift 6-safe cleanup: perform async removal on a detached task
    deinit {
        Task.detached { [handle = authStateListenerHandle] in
            if let handle {
                Auth.auth().removeStateDidChangeListener(handle)
            }
        }
    }

    private func listenToAuthChanges() {
        // ✅ Use weak capture to avoid lifetime issues
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            Task { @MainActor in
                withAnimation {
                    self.isUserLoggedIn = (user != nil)
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            withAnimation {
                isUserLoggedIn = false
            }
        } catch {
            print("❌ Error signing out: \(error.localizedDescription)")
        }
    }
}
