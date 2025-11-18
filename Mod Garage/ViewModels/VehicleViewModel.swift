//
//  VehicleViewModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 14/11/2025.
//

import Foundation
import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth

@MainActor
class VehicleViewModel: ObservableObject {
    
    @Published var isShowingAddVehicle = false
    @Published var vehicles: [VehicleModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    
    // Add a new vehicle
    func addVehicle(_ vehicle: VehicleModel) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "No logged in user."
            return
        }
        
        let path = db
            .collection("users")
            .document(uid)
            .collection("vehicles")
            .document(vehicle.id)
        
        do {
            try path.setData(from: vehicle)
            await loadVehicles()
            isShowingAddVehicle = false
        } catch {
            errorMessage = "Failed to save vehicle: \(error.localizedDescription)"
        }
    }
    
    // Load vehicles list
    func loadVehicles() async {
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
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let decoded = try snapshot.documents.map { doc in
                try doc.data(as: VehicleModel.self)
            }
            
            vehicles = decoded
        } catch {
            errorMessage = "Failed to load vehicles: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
