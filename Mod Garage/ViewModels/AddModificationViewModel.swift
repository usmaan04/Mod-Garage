//
//  AddModificationViewModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 12/01/2026.
//

import Foundation
import Combine
import SwiftUI
import FirebaseAuth
import FirebaseStorage
import PhotosUI

@MainActor
final class AddModificationViewModel: ObservableObject {

    // Preset types fo rth euser to choose from
    let modTypes = ["Exhaust", "Windows", "Lights", "Engine", "Bodykit"]

    // Fields that the user fills out
    @Published var modType: String = "Select Type"
    @Published var modName: String = ""
    @Published var modCost: Double = 0
    @Published var modDesc: String = ""
    @Published var modDate: Date = Date()
    
    // Properties for picking and displaying 'Before' and 'After' photos
    @Published var beforeImageItem: PhotosPickerItem?
    @Published var afterImageItem: PhotosPickerItem?
    @Published var beforeImage: UIImage?
    @Published var afterImage: UIImage?

    @Published var showDatePicker = false
    @Published var errorMessage: String? = nil
    
    @Published var vehicleId: String = ""
    
    var savedMod: ModificationModel? = nil

    // Callback to tell parent view that modification is ready to be saved
    var onModificationReady: ((ModificationModel) -> Void)?
    
    // Access to Firebase Cloud Storage
    private let storage = Storage.storage()
    
    // Convert selected photo into a display compatible format
    func loadBeforeImage() async {
        guard let item = beforeImageItem else { return }

        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                beforeImage = image
            }
        } catch {
            errorMessage = "Failed to load before image."
        }
    }

    // Convert selected photo into a display compatible format
    func loadAfterImage() async {
        guard let item = afterImageItem else { return }

        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                afterImage = image
            }
        } catch {
            errorMessage = "Failed to load after image."
        }
    }

    // Validates user entered/enterable fields
    func isFormValid() -> Bool{
        errorMessage = nil

        // Prevent empty fields
        if modType == "Select Type" || modName.isEmpty || modDesc.isEmpty {
            errorMessage = "Please fill in all fields"
            return false
        }

        // Ensure name is not more than 40 characters
        if modName.count > 40 {
            errorMessage = "Please enter a shorter name"
            return false
        }
        
        // Ensure description is not more than 300 characters
        if modDesc.count > 300 {
            errorMessage = "Please enter a shorter description"
            return false
        }
        
        return true
    }
    
    // Called when user presses save, calls function to upload images to Firestore and create modification model
    func confirmModification() async {
        
        // Check form validation
        guard isFormValid() else {
            return
        }

        var finalBeforeURLString = ""
        var finalAfterURLString = ""

        do {
            let modificationId = UUID().uuidString

            // Upload before image or set a placeholder one
            if let beforeImage {
                finalBeforeURLString = try await uploadImage(beforeImage, vehicleId, modificationId)
            } else if let placeholder = UIImage(named: "carimg") {
                finalBeforeURLString = try await uploadImage(placeholder, vehicleId,modificationId)
            } else {
                throw NSError(
                    domain: "AddModificationViewModel",
                    code: 404,
                    userInfo: [NSLocalizedDescriptionKey: "Missing placeholder image asset 'carimg'."]
                )
            }

            // Upload after image or set a placeholder one
            if let afterImage {
                finalAfterURLString = try await uploadImage(afterImage, vehicleId ,modificationId)
            } else if let placeholder = UIImage(named: "carimg") {
                finalAfterURLString = try await uploadImage(placeholder, vehicleId, modificationId)
            } else {
                throw NSError(
                    domain: "AddModificationViewModel",
                    code: 404,
                    userInfo: [NSLocalizedDescriptionKey: "Missing placeholder image asset 'carimg'."]
                )
            }
            
            // Create modifcation model using the inputted and calculated values
            let newModification = ModificationModel(
                id: modificationId,
                type: modType,
                name: modName,
                cost: modCost,
                description: modDesc,
                date: modDate,
                beforeImageURL: finalBeforeURLString,
                afterImageURL: finalAfterURLString,
                createdAt: Date()
            )

            // Set onModificationReady for saving
            onModificationReady?(newModification)
            
            // Set saved mod for testing
            savedMod = newModification

            resetView()
        } catch {
            errorMessage = "Failed to upload modification"
        }
    }
    
    // Helper function that sends a single image to Firebase Cloud Storage and returns the URL String
    private func uploadImage(_ image: UIImage, _ vehicleId: String, _ modificationId: String) async throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(
                domain: "AddModificationViewModel",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No authenticated user."]
            )
        }

        // Compress image
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            throw NSError(
                domain: "AddModificationViewModel",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Could not process selected image."]
            )
        }

        // Decide the path (before/after) based on which image is being uploaded
        let pathSuffix = (image === self.beforeImage) ? "before.jpg" : "after.jpg"

        // Set the folder structure where the file will be saved in Firestore
        let ref = storage.reference().child("modification_images/\(uid)/\(vehicleId)/\(modificationId)/\(pathSuffix)")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        // Upload image and get the url for the image
        _ = try await ref.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await ref.downloadURL()

        return downloadURL.absoluteString
    }

    // Reset all fields back to default
    func resetView() {
        modType = "Select Type"
        modName = ""
        modCost = 0
        modDesc = ""
        modDate = Date()
        beforeImage = nil
        afterImage = nil
        errorMessage = nil
    }
}

