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
import FirebaseStorage

@MainActor
final class AppViewModel: ObservableObject {
    @Published var isUserLoggedIn: Bool = Auth.auth().currentUser != nil
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    //  Listener that watches Firebase and triggers every time a user logs in or out
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    // Access to Firebase database and storage
    let db = Firestore.firestore()
    private let storage = Storage.storage()

    init() {
        listenToAuthChanges()
    }

    // Cleans up the listener when the app is closed to save memory
    deinit {
        Task.detached { [handle = authStateListenerHandle] in
            if let handle {
                Auth.auth().removeStateDidChangeListener(handle)
            }
        }
    }

    // Constantly monitors Firebase to see if the user's login status changes
    private func listenToAuthChanges() {
        // Use weak capture to avoid lifetime issues
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            Task { @MainActor in
                withAnimation {
                    // Automatically updates the UI when the user logs in or out
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

    // Sign-out function that tells Firebase to end the session
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

    // Deletes everything: Firestore data, Storage photos, and the Login account
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(
                domain: "AppViewModel",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No authenticated user."]
            )
        }

        let uid = user.uid

        // Delete all app data from Firestore + Storage
        try await deleteAllUserData(uid: uid)

        // Delete auth user last
        do {
            try await user.delete()
            withAnimation {
                self.isUserLoggedIn = false
            }
        } catch {
            throw error
        }
    }

    // Full account cleanup
    private func deleteAllUserData(uid: String) async throws {
        let userRef = db.collection("users").document(uid)
        let vehiclesRef = userRef.collection("vehicles")

        // Fetch all vehicles first
        let vehicleSnapshot = try await vehiclesRef.getDocuments()

        for vehicleDoc in vehicleSnapshot.documents {
            let vehicleId = vehicleDoc.documentID
            let vehicleRef = vehiclesRef.document(vehicleId)

            // Delete vehicle subcollections
            try await deleteCollection(vehicleRef.collection("modifications"))
            try await deleteCollection(vehicleRef.collection("fuelLogs"))

            // Delete vehicle document
            try await vehicleRef.delete()

            // Delete vehicle/modification/profile images from Storage
            try await deleteStorageFolderIfExists("vehicle_images/\(uid)/\(vehicleId)")
            try await deleteStorageFolderIfExists("modification_images/\(uid)/\(vehicleId)")
            try await deleteStorageFolderIfExists("profile_images/\(uid)")
        }

        // Delete top-level user document last
        try await userRef.delete()
    }

    // Loops through a collection s and deletes every document inside
    private func deleteCollection(_ collection: CollectionReference) async throws {
        let snapshot = try await collection.getDocuments()
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }

    // Deletes folders of images
    private func deleteStorageFolderIfExists(_ path: String) async throws {
        let folderRef = storage.reference().child(path)

        do {
            let result = try await folderRef.listAll()

            for item in result.items {
                try await item.delete()
            }

            for prefix in result.prefixes {
                try await deleteStorageFolderRecursively(prefix)
            }
        } catch {
        }
    }

    private func deleteStorageFolderRecursively(_ folderRef: StorageReference) async throws {
        let result = try await folderRef.listAll()

        for item in result.items {
            try await item.delete()
        }

        for prefix in result.prefixes {
            try await deleteStorageFolderRecursively(prefix)
        }
    }
}

