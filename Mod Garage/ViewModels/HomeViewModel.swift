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
    @Published var selectedTab: Tab = .home
    @Published var primaryVehicle : VehicleModel?
    @Published var modifications: [ModificationModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

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
                print(" Firestore fetch error: \(error.localizedDescription)")
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
    
    // Format Date as Day(st, nd, rd, th) Month Year
    func dateFormatter(_ date: Date?) -> String {
        guard let date = date else { return "Could not get date" }

        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)

        // Determine the suffix (st, nd, rd, th)
        let suffix: String
        switch day {
        case 1, 21, 31: suffix = "st"
        case 2, 22: suffix = "nd"
        case 3, 23: suffix = "rd"
        default: suffix = "th"
        }

        // Format month and year
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        let monthYear = formatter.string(from: date)

        return "\(day)\(suffix) \(monthYear)"
    }
    
    // Format Date as Day(st, nd, rd, th) Month Year
    func modDateFormatter(_ date: Date?) -> String {
        guard let date = date else { return "Could not get date" }

        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)

        // Determine the suffix (st, nd, rd, th)
        let suffix: String
        switch day {
        case 1, 21, 31: suffix = "st"
        case 2, 22: suffix = "nd"
        case 3, 23: suffix = "rd"
        default: suffix = "th"
        }

        // Format month and year
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        let monthYear = formatter.string(from: date)

        return "\(day) \(monthYear)"
    }
    
    func loadVehicleData() async{
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "No logged in user."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let query = db
                .collection("users")
                .document(uid)
                .collection("vehicles")
                .whereField("isPrimary", isEqualTo: true)
                .limit(to: 1)
            
            let snapshot = try await query.getDocuments()
            
            if snapshot.documents.isEmpty {
                primaryVehicle = nil
                return
            }
            
            let decoded = try snapshot.documents.map { doc in
                try doc.data(as: VehicleModel.self)
            }
            
            let vehicle = decoded.first
            primaryVehicle = vehicle
        } catch {
            errorMessage = "Failed to load vehicle: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // Load modification list
    func loadModifications(_ vehicleId: String) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "No logged in user."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let snapshot = try await db
                .collection("users")
                .document(uid)
                .collection("vehicles")
                .document(vehicleId)
                .collection("modifications")
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let decoded = try snapshot.documents.map { doc in
                try doc.data(as: ModificationModel.self)
            }
            
            modifications = decoded
        } catch {
            errorMessage = "Failed to load modifications: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
