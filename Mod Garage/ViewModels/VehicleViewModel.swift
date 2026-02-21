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
    
    @AppStorage(NotificationKeys.needsSync) private var needsSync: Bool = false
    
    @Published var isShowingAddVehicle = false
    @Published var vehicles: [VehicleModel] = []
    @Published var vehicleToPass: VehicleModel?
    @Published var showDetails: Bool = false
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    
    // Returns the signed number of days between today and the provided date.
    func daysBetweenToday(date: Date?) -> Int {
        guard let date = date else { return 0 }
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let targetStart = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.day], from: todayStart, to: targetStart)
        return components.day ?? 0
    }
    
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
            // Set all others as false if selected vehicle is primary
            if vehicle.isPrimary {
                do {
                    try await PrimaryVehicleService.setPrimary(
                        vehicleId: vehicle.id,
                        for: uid
                    )
                } catch {
                    errorMessage = "Failed to set primary vehicle: \(error.localizedDescription)"
                    return
                }
            }
            needsSync = true
            // Refresh list
            await loadVehicles()
            isShowingAddVehicle = false
        } catch {
            errorMessage = "Failed to save vehicle: \(error.localizedDescription)"
        }
    }
    
    func makePrimary(_ vehicle: VehicleModel) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "No logged in user."
            return
        }

        do {
            try await PrimaryVehicleService.setPrimary(
                vehicleId: vehicle.id,
                for: uid
            )

            // Refresh list
            await loadVehicles()

        } catch {
            errorMessage = "Failed to make primary: \(error.localizedDescription)"
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
                .order(by: "createdAt", descending: false)
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
    
    func deleteVehicle(_ vehicle: VehicleModel) async {
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
            // If the vehicle being deleted is primary → assign a new one
            if vehicle.isPrimary {
                try await PrimaryVehicleService.setOtherPrimary(
                    deletingVehicleId: vehicle.id,
                    for: uid
                )
            }
            
            // Delete the vehicle itself
            try await path.delete()
            
            needsSync = true
            
            // Refresh list
            await loadVehicles()
            
        } catch {
            errorMessage = "Failed to delete vehicle: \(error.localizedDescription)"
        }
    }
    
}

