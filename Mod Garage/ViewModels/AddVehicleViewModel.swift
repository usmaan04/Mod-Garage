//
//  AddVehicleViewModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 15/11/2025.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth

// Set string format (Sentence case)
extension String {
    var sentenceCased: String {
        let lower = self.lowercased()
        return lower.prefix(1).uppercased() + lower.dropFirst()
    }
}

// Format Date as YYYY-MM-DD
func formatDVLADate(_ dateString: String?) -> Date? {
    guard let dateString else { return nil }
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = .current
    return formatter.date(from: dateString)
}

@MainActor
class AddVehicleViewModel: ObservableObject {
    @Published var registration: String = ""
    @Published var isLoading: Bool = false
    @Published var dvlaVehicle: DVLAResponseModel? = nil
    @Published var errorMessage: String? = nil
    @Published var hasConfirmedDVLA = false
    @Published var model = ""
    @Published var makePrimary = false
    
    // Is set when vehicle is ready
    var onVehicleReady: ((VehicleModel) -> Void)?
    
    var existingVehicleCount: Int = 0
    
    // DVLA Search
    func searchRegistration() {
        // Prevent spaces or empty inputs
        guard !registration.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        isLoading = true
        errorMessage = nil
        dvlaVehicle = nil

        Task {
            do {
                let result = try await DVLAService().fetchVehicle(for: registration)
                dvlaVehicle = result
            } catch {
                errorMessage = "Could not find vehicle. Please check the registration."
            }

            isLoading = false
        }
    }
    
    // Validate model & create a VehicleModel
    func confirmVehicle() {
        
        errorMessage = nil
        
        // Prevent spaces or empty inputs
        let trimmedModel = model.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedModel.isEmpty {
            errorMessage = "Please confirm model name"
            return
        }
        
        // Ensure model length is less than 11 characters
        if trimmedModel.count > 10 {
            errorMessage = "Invalid model name"
            return
        }
        
        // Ensure there is a DVLA result
        guard let vehicle = dvlaVehicle else {
            errorMessage = "DVLA data missing"
            return
        }
        
        // Ensure there is a Firebase user
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "You must be logged in"
            return
        }
                
        var isPrimaryForThisVehicle = makePrimary
                
        // Make isPrimary false if user doesn't have a car
        if existingVehicleCount == 0 {
            isPrimaryForThisVehicle = true
        }

        // Build VehicleModel
        let newVehicle = VehicleModel(
            id: UUID().uuidString,
            userId: uid,
            registration: vehicle.registrationNumber.uppercased(),
            make: vehicle.make.sentenceCased,
            model: trimmedModel.sentenceCased,
            year: vehicle.yearOfManufacture ?? 0,
            colour: vehicle.colour.sentenceCased,
            fuelType: vehicle.fuelType.sentenceCased,
            motExpiryDate: formatDVLADate(vehicle.motExpiryDate),
            motStatus: vehicle.motStatus?.sentenceCased,
            taxExpiryDate: formatDVLADate(vehicle.taxDueDate),
            taxStatus: vehicle.taxStatus?.sentenceCased,
            imageURL: nil,
            isPrimary: isPrimaryForThisVehicle,
            createdAt: Date()
        )
        
        // Send to vehicle view to save in Firestore
        onVehicleReady?(newVehicle)
        
        // Reset internal UI state
        resetView()
    }
    
    func testVehicleModel() throws -> VehicleModel {
        guard let vehicle = dvlaVehicle else {
            throw NSError(domain: "DVLA missing", code: 0)
        }

        guard let uid = "TEST_USER" as String? else {
            throw NSError(domain: "User missing", code: 0)
        }

        return VehicleModel(
            id: "TEST_ID",
            userId: uid,
            registration: vehicle.registrationNumber.uppercased(),
            make: vehicle.make.sentenceCased,
            model: model.sentenceCased,
            year: vehicle.yearOfManufacture ?? 0,
            colour: vehicle.colour.sentenceCased,
            fuelType: vehicle.fuelType.sentenceCased,
            motExpiryDate: formatDVLADate(vehicle.motExpiryDate),
            motStatus: vehicle.motStatus?.sentenceCased,
            taxExpiryDate: formatDVLADate(vehicle.taxDueDate),
            taxStatus: vehicle.taxStatus?.sentenceCased,
            imageURL: nil,
            isPrimary: existingVehicleCount == 0,
            createdAt: Date()
        )
    }
    
    // Reset all states
    func resetView() {
        registration = ""
        dvlaVehicle = nil
        model = ""
        makePrimary = false
        hasConfirmedDVLA = false
        errorMessage = nil
    }
}


