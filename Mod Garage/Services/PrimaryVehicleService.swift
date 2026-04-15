//
//  PrimaryVehicleService.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 19/11/2025.
//


import FirebaseFirestore
import FirebaseAuth

struct PrimaryVehicleService {

    static let db = Firestore.firestore()

    // Set a specific vehicle as primary
    static func setPrimary(vehicleId: String, for userId: String) async throws {

        let userVehiclesRef = db.collection("users")
            .document(userId)
            .collection("vehicles")

        // Gets any vehicles marked as primary
        let primarySnapshot = try await userVehiclesRef
            .whereField("isPrimary", isEqualTo: true)
            .getDocuments()

        // Create a batch multiple write
        let batch = db.batch()

        // Unset all current primary vehicles
        for doc in primarySnapshot.documents {
            batch.updateData(["isPrimary": false], forDocument: doc.reference)
        }

        // Set the chosen vehicle as primary
        let selectedVehicleRef = userVehiclesRef.document(vehicleId)
        batch.updateData(["isPrimary": true], forDocument: selectedVehicleRef)

        // Commit batch
        try await batch.commit()
    }
    
    // If selected vehicle to delete is primary delete it and set a replacement as primary
    static func deleteAndSetNewPrimary(deletingVehicleId: String, for userId: String) async throws {
        
        let vehiclesRef = db.collection("users").document(userId).collection("vehicles")
        let batch = db.batch()
        
        // Add the delete operation to the batch
        let docToDelete = vehiclesRef.document(deletingVehicleId)
        batch.deleteDocument(docToDelete)
        
        // Find a replacement vehicle
        let snapshot = try await vehiclesRef.getDocuments()
        
        // Filter to find the next best vehicle
        let remainingVehicles = snapshot.documents
            .filter { $0.documentID != deletingVehicleId }
            .sorted {
                let date1 = $0.data()["createdAt"] as? Date ?? Date.distantPast
                let date2 = $1.data()["createdAt"] as? Date ?? Date.distantPast
                return date1 > date2
            }

        // Add the setting a new primary to the batch
        if let newPrimary = remainingVehicles.first {
            batch.updateData(["isPrimary": true], forDocument: newPrimary.reference)
        }
        
        // Commit everything at once
        try await batch.commit()
    }
}
