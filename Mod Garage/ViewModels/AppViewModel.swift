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
import FirebaseFirestore

@MainActor
final class AppViewModel: ObservableObject {
    @Published var isUserLoggedIn: Bool = Auth.auth().currentUser != nil
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        listenToAuthChanges()
    }

    //  Swift 6-safe cleanup: perform async removal on a detached task
    deinit {
        Task.detached { [handle = authStateListenerHandle] in
            if let handle {
                Auth.auth().removeStateDidChangeListener(handle)
            }
        }
    }

    private func listenToAuthChanges() {
        // Use weak capture to avoid lifetime issues
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            Task { @MainActor in
                withAnimation {
                    self.isUserLoggedIn = (user != nil)
                }
            }
        }
    }

    // Deletes the user's Firestore document
    private func deleteUserDocumentFromFirestore(uid: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Firestore.firestore().collection("users").document(uid).delete { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    // Deletes the currently authenticated user
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "AppViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user."])
        }

        // Delete Firestore user document first to avoid orphaned data
        do {
            try await deleteUserDocumentFromFirestore(uid: user.uid)
        } catch {
            throw error
        }

        // Then delete the auth user
        do {
            try await user.delete()
            // Update app state on main actor
            withAnimation {
                self.isUserLoggedIn = false
            }
        } catch {
            throw error
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            withAnimation {
                isUserLoggedIn = false
            }
        } catch {
            print(" Error signing out: \(error.localizedDescription)")
        }
    }

    /// Convenience method to delete the account and handle errors by logging.
    /// Prefer the async/throws variant when you need to present errors to the user.
    func deleteAccountSafely() {
        Task { @MainActor in
            do {
                try await deleteAccount()
            } catch {
                // Common case: requiresRecentLogin. The UI should guide the user to reauthenticate.
                if let authError = error as NSError?, authError.domain == AuthErrorDomain,
                   AuthErrorCode(rawValue: authError.code) == .requiresRecentLogin {
                    print("Delete account failed: requires recent login. Prompt user to reauthenticate.")
                } else {
                    print("Delete account failed: \(error.localizedDescription)")
                }
            }
        }
    }
}

