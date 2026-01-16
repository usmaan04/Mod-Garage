//
//  VehicleDetailViewModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 10/01/2026.
//

import Foundation
import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class VehicleDetailViewModel: ObservableObject {

    @Published var isShowingAddModification = false
    @Published var modifications: [ModificationModel] = []
    @Published var isShowingAddFuelLog = false
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let db = Firestore.firestore()

    // Add a new vehicle
    func addModification(_ modification: ModificationModel, vehicleId: String) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "No logged in user."
            return
        }
        
        let modsCollection = db
            .collection("users")
            .document(uid)
            .collection("vehicles")
            .document(vehicleId)
            .collection("modifications")
        
        do {
            try modsCollection.addDocument(from: modification)
            await loadModifications(vehicleId)
            isShowingAddModification = false
        
        } catch {
            errorMessage = "Failed to save modification: \(error.localizedDescription)"
        }
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
                .collection("modifcations")
                .order(by: "createdAt", descending: false)
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
