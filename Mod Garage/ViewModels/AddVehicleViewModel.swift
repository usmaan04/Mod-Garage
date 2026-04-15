//
//  AddVehicleViewModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 15/11/2025.
//

import Foundation
import SwiftUI
import Combine
import PhotosUI
import FirebaseAuth
import FirebaseStorage

// Set strings into sentence case
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
    // Fields that the user fills out
    @Published var registration: String = ""
    @Published var model = ""
    
    // States
    @Published var isLoading: Bool = false
    @Published var dvlaVehicle: DVLAResponseModel? = nil
    @Published var errorMessage: String? = nil
    @Published var hasConfirmedDVLA = false
    @Published var makePrimary = false
    
    @Published var carImageItem: PhotosPickerItem?

    @Published var carImage: UIImage?
    
    // Callback to tell parent view that vehicle is ready to be saved
    var onVehicleReady: ((VehicleModel) -> Void)?
    
    var existingVehicleCount: Int = 0
    
    // Access to Firebase Cloud Storage
    private let storage = Storage.storage()
    
    // Search the DVLA database using the registration
    func searchRegistration() {
        // Prevent spaces or empty inputs
        guard !registration.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        isLoading = true
        errorMessage = nil
        dvlaVehicle = nil

        Task {
            do {
                // Calls the DVLA Service
                let result = try await DVLAService().fetchVehicle(for: registration)
                dvlaVehicle = result
            } catch {
                errorMessage = "Could not find vehicle. Please check the registration"
            }

            isLoading = false
        }
    }
    
    // Convert selected photo into a display compatible format
    func loadImage() async {
        guard let item = carImageItem else { return }

        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                carImage = image
            }
        } catch {
            errorMessage = "Failed to load before image."
        }
    }
    
    // Validates data, calls function to upload images & creates a VehicleModel
    func confirmVehicle() async {
        
        errorMessage = nil
        
        // Prevent spaces or empty inputs
        let trimmedModel = model.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedModel.isEmpty {
            errorMessage = "Please confirm model name"
            return
        }
        
        // Ensure model length is not more than 10 characters
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
                
        // Make isPrimary true if user doesn't have a vehicle
        var isPrimaryForThisVehicle = makePrimary
        if existingVehicleCount == 0 {
            isPrimaryForThisVehicle = true
        }
        

        // Create vehicle model using the inputted and calculated values
        do {
            let vehicleId = UUID().uuidString
            var imageURLString = ""

            // Use provided images, or fall back to asset "carimg"
            if let carImage {
                imageURLString = try await uploadImage(carImage, vehicleId)
            } else if let placeholder = UIImage(named: "carPlaceholder") {
                imageURLString = try await uploadImage(placeholder, vehicleId)
            } else {
                throw NSError(
                    domain: "AddModificationViewModel",
                    code: 404,
                    userInfo: [NSLocalizedDescriptionKey: "Missing placeholder image asset 'carimg'."]
                )
            }
            
            // Build model using URL strings (or nil)
            let newVehicle = VehicleModel(
                id: vehicleId,
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
                imageURL: imageURLString,
                isPrimary: isPrimaryForThisVehicle,
                createdAt: Date()
            )

            // Set onVehicleLogReady for saving
            onVehicleReady?(newVehicle)

            resetView()
        } catch {
            errorMessage = "Failed to upload modification: \(error.localizedDescription)"
        }
    }
    
    // Helper function that sends a single image to Firebase Cloud Storage and returns the URL String
    private func uploadImage(_ image: UIImage, _ vehicleId: String) async throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(
                domain: "AddVehicleViewModel",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No authenticated user."]
            )
        }

        // Compress image
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            throw NSError(
                domain: "AddVehicleViewModel",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Could not process selected image."]
            )
        }

        // Set the folder structure where the file will be saved in Firestore
        let ref = storage.reference().child("vehicle_images/\(uid)/\(vehicleId)/image.jpg")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        // Upload image and get the url for the image
        _ = try await ref.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await ref.downloadURL()

        return downloadURL.absoluteString
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
        carImage = nil
    }
}


