//
//  SettingsViewModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 12/11/2025.
//

import Combine
import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var profilePhotoURL: URL?
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var memberDate: String = ""
    @Published var selectedTab: Tab = .home
    // App appearance preference: "system", "light", or "dark"
    @AppStorage("preferredColorScheme") private var preferredColorSchemeRaw: String = "system"
    @Published var isEmailPasswordUser: Bool = false
    @Published var showProfile: Bool = false
    @Published var showNotification: Bool = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    // Override app appearance
    var overrideColorScheme: ColorScheme? {
        get {
            switch preferredColorSchemeRaw {
            case "light": return .light
            case "dark": return .dark
            default: return nil // follow system
            }
        }
        set {
            if let v = newValue {
                preferredColorSchemeRaw = (v == .dark) ? "dark" : "light"
            } else {
                preferredColorSchemeRaw = "system"
            }
            objectWillChange.send()
        }
    }
    
    private let db = Firestore.firestore()

    init() {
        updateAuthProviderState()
        fetchUserDetails()
    }

    func fetchUserDetails() {
        guard let user = Auth.auth().currentUser else {
            self.isEmailPasswordUser = false
            name = "User"
            email = "Email"
            profilePhotoURL = nil
            return
        }
        
        updateAuthProviderState()
        
        profilePhotoURL = user.photoURL
        
        let uid = user.uid
        let userEmailAtCapture = user.email

        // Fetch the name and email from Firestore for email/password users
        db.collection("users").document(uid).getDocument { [weak self] document, error in
            guard let self = self else { return }

            if let error = error {
                print(" Firestore fetch error: \(error.localizedDescription)")
                Task { @MainActor in
                    self.name = "User"
                    self.email = "Email"
                    self.memberDate = "2026"
                }
                return
            }

            if let document = document, document.exists {
                let data = document.data() ?? [:]
                let fetchedName = data["name"] as? String ?? "User"
                let fetchedEmail = data["email"] as? String ?? userEmailAtCapture ?? ""
                
                // Date formatter
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM yyyy"
                
                var formattedDate = ""
                if let timestamp = data["createdAt"] as? Timestamp {
                    let date = timestamp.dateValue()
                    formattedDate = formatter.string(from: date)
                }
                
                DispatchQueue.main.async {
                    self.name = fetchedName
                    self.email = fetchedEmail
                    self.memberDate = formattedDate
                }
            } else {
                Task { @MainActor in
                    self.name = "User"
                    self.email = userEmailAtCapture ?? ""
                    self.memberDate = "2026"
                }
            }
        }
    }

    // Check to see how user is logged in (Email/password or Google)
    private func updateAuthProviderState() {
        guard let user = Auth.auth().currentUser else { return }
        let providerIDs = user.providerData.map { $0.providerID }
        if providerIDs.contains("password") {
            self.isEmailPasswordUser = true
        } else {
            self.isEmailPasswordUser = false
        }
    }
}
