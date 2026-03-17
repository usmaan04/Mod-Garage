//
//  ProfileViewModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 28/02/2026.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil

    private let db = Firestore.firestore()

    init() {
        Task { await loadProfile() }
    }

    func loadProfile() async {
        guard let user = Auth.auth().currentUser else {
            self.errorMessage = "No logged in user."
            return
        }

        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        successMessage = nil

        do {
            // Populate from Auth first
            self.email = user.email ?? ""
            if let displayName = user.displayName, !displayName.isEmpty {
                self.name = displayName
            }

            // Then try Firestore user document for a stored name
            let doc = try await db.collection("users").document(user.uid).getDocument()
            if let data = doc.data(), let firestoreName = data["name"] as? String, !firestoreName.isEmpty {
                self.name = firestoreName
            }
        } catch {
            self.errorMessage = "Failed to load profile: \(error.localizedDescription)"
        }
    }

    func updateProfile() async {
        guard let user = Auth.auth().currentUser else {
            self.errorMessage = "No logged in user."
            return
        }

        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        successMessage = nil

        do {
            // Update email if changed
            if !email.isEmpty, email != user.email {
                Auth.auth().currentUser?.updateEmail(to: email) { error in
                }
            }

            // Update password if provided
            if !password.isEmpty {
                try await user.updatePassword(to: password)
                password = ""
            }

            // Update displayName via profile change request
            if user.displayName != name {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = name
                try await changeRequest.commitChanges()
            }

            // Persist name in Firestore user document
            try await db.collection("users").document(user.uid).setData(["name": name], merge: true)

            successMessage = "Profile updated"
        } catch {
            self.errorMessage = "Failed to update profile: \(error.localizedDescription)"
        }
    }
}

