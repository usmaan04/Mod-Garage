//
//  HomeViewModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 10/11/2025.
//

import Combine
import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class HomeViewModel: ObservableObject {
    @Published var name: String = ""

    private let db = Firestore.firestore()

    init() {
        fetchUserName()
    }

    func fetchUserName() {
        guard let user = Auth.auth().currentUser else {
            name = "User"
            return
        }

        // Try to use Google display name first
        if let displayName = user.displayName, !displayName.isEmpty {
            name = displayName
            return
        }

        // Otherwise, fetch the name from Firestore for email/password users
        db.collection("users").document(user.uid).getDocument { [weak self] document, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ Firestore fetch error: \(error.localizedDescription)")
                Task { @MainActor in
                    self.name = "User"
                }
                return
            }

            if let document = document, document.exists,
               let fetchedName = document.data()?["name"] as? String {
                DispatchQueue.main.async {
                    self.name = fetchedName
                }
            } else {
                Task { @MainActor in
                    self.name = "User"
                }
            }
        }
    }
}
