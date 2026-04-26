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
import FirebaseStorage

// Handles the logic for the collection of vehciels in the users account
@MainActor
class VehicleViewModel: ObservableObject {
    
    // Communicates with the NotificationViewModel to re-sync notifications
    @AppStorage(NotificationKeys.needsSync) private var needsSync: Bool = false
    
    // UI state properties for controlling navigation and showning sheets/overlays
    @Published var isShowingAddVehicle = false
    @Published var isShowingEditVehicle = false
    @Published var vehicles: [VehicleModel] = []
    @Published var vehicleToEdit: VehicleModel?
    @Published var vehicleToPass: VehicleModel?
    @Published var showDetails: Bool = false
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    
    // Calculates days remaining for MOT/Tax countdowns
    func daysBetweenToday(date: Date?) -> Int {
        guard let date = date else { return 0 }
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let targetStart = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.day], from: todayStart, to: targetStart)
        return components.day ?? 0
    }
    
    // Adds a new vehicle into the vehicles subcollection
    func addVehicle(_ vehicle: VehicleModel) async -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "No logged in user."
            return false
        }
        
        let path = db
            .collection("users")
            .document(uid)
            .collection("vehicles")
            .document(vehicle.id)
        
        do {
            try path.setData(from: vehicle)
            // Set all others as false if selected vehicle is  chosen as primary
            if vehicle.isPrimary {
                do {
                    try await PrimaryVehicleService.setPrimary(
                        vehicleId: vehicle.id,
                        for: uid
                    )
                } catch {
                    errorMessage = "Failed to set primary vehicle: \(error.localizedDescription)"
                    return false
                }
            }
            
            // Trigger a notification sync
            needsSync = true
            
            // Refresh list and close overlay
            await loadVehicles()
            return true
        } catch {
            errorMessage = "Failed to save vehicle: \(error.localizedDescription)"
            return false
        }
    }
    
    // Makes the chosen vehicle primary
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
    
    // Gets the vehicles stored in Firestore
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
    
    // Deletes a vehicle from users account/Firestore
    func deleteVehicle(_ vehicle: VehicleModel) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "No logged in user."
            return
        }
        
        let vehicleRef = db
            .collection("users")
            .document(uid)
            .collection("vehicles")
            .document(vehicle.id)
        
        do {
            // If the vehicle being deleted is primary, assign a new one
            if vehicle.isPrimary {
                try await PrimaryVehicleService.deleteAndSetNewPrimary(
                    deletingVehicleId: vehicle.id,
                    for: uid
                )
            }
            
            // Delete all the vehucles mods and fuel logs
            try await deleteCollection(vehicleRef.collection("modifications"))
            try await deleteCollection(vehicleRef.collection("fuelLogs"))
            
            // Delete all the images related to the vehicle and it's mods
            try await deleteStorageFolder("vehicle_images/\(uid)/\(vehicle.id)")
            try await deleteStorageFolder("modification_images/\(uid)/\(vehicle.id)")
            
            // Delete the vehicle
            try await vehicleRef.delete()
            
            // Trigger a notification sync
            needsSync = true
            
            // Refresh list
            await loadVehicles()
            
        } catch {
            errorMessage = "Failed to delete vehicle: \(error.localizedDescription)"
        }
    }
    
    // Loops through a collection s and deletes every document inside
    private func deleteCollection(_ collection: CollectionReference) async throws {
        let snapshot = try await collection.getDocuments()
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
    
    // Deletes folders of images
    private func deleteStorageFolder(_ path: String) async throws {
        let storageRef = Storage.storage().reference().child(path)
        
        do {
            let list = try await storageRef.listAll()
            
            // Delete files
            for item in list.items {
                try await item.delete()
            }
            
            // Recursively delete subfolders
            for prefix in list.prefixes {
                try await deleteStorageFolder("\(path)/\(prefix.name)")
            }
        } catch {
        }
    }
    
}

