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
    
    // Set the latest vehicle as primary
    static func setOtherPrimary(deletingVehicleId: String, for userId: String) async throws {
        
        let vehiclesRef = db.collection("users")
            .document(userId)
            .collection("vehicles")
        
        // Get all vehicles EXCEPT the one we are deleting
        let snapshot = try await vehiclesRef
            .whereField("id", isNotEqualTo: deletingVehicleId)
            .order(by: "createdAt", descending: true) // latest added first
            .getDocuments()
        
        // If no vehicles left → nothing to set primary
        guard let firstDoc = snapshot.documents.first else { return }
        
        let batch = db.batch()
        
        // Set this remaining vehicle to primary
        batch.updateData(["isPrimary": true], forDocument: firstDoc.reference)
        
        try await batch.commit()
    }
}
