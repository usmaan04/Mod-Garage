//
//  FuelViewModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 08/01/2026.
//

import Combine
import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class FuelViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var primaryVehicle : VehicleModel?
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let db = Firestore.firestore()
    
    init() {
        Task {
            await loadVehicleData()
        }
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
}
