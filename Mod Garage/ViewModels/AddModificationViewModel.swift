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

    let modTypes = ["Exhaust", "Windows", "Lights", "Engine", "Bodykit"]

    @Published var modType: String = "Select Type"
    @Published var modName: String = ""
    @Published var modCost: Double = 0
    @Published var modDesc: String = ""
    @Published var modDate: Date = Date()
    
    @Published var beforeImageItem: PhotosPickerItem?
    @Published var afterImageItem: PhotosPickerItem?

    @Published var beforeImage: UIImage?
    @Published var afterImage: UIImage?

    @Published var showDatePicker = false
    @Published var errorMessage: String? = nil
    
    @Published var vehicleId: String = ""

    // Called when the modification is ready to be saved to Firestore by the parent view
    var onModificationReady: ((ModificationModel) -> Void)?
    
    private let storage = Storage.storage()
    
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

    func confirmModification() async {
        errorMessage = nil

        // Validate
        if modType == "Select Type" || modName.isEmpty || modDesc.isEmpty {
            errorMessage = "Please fill all fields"
            return
        }

        // Ensure name is not more than 40 characters
        if modName.count > 40 {
            errorMessage = "Invalid modification name"
            return
        }

        var finalBeforeURLString = ""
        var finalAfterURLString = ""

        do {
            let modificationId = UUID().uuidString

            // Use provided images, or fall back to asset "carimg"
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
            
            // Build model using URL strings (or nil)
            let newModification = ModificationModel(
                id: modificationId,
                type: modType,
                name: modName.sentenceCased,
                cost: modCost,
                description: modDesc,
                date: modDate,
                beforeImageURL: finalBeforeURLString,
                afterImageURL: finalAfterURLString,
                createdAt: Date()
            )

            // Send to parent to save into Firestore
            onModificationReady?(newModification)

            resetView()
        } catch {
            errorMessage = "Failed to upload modification: \(error.localizedDescription)"
        }
    }
    
    private func uploadImage(_ image: UIImage, _ vehicleId: String, _ modificationId: String) async throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(
                domain: "AddModificationViewModel",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No authenticated user."]
            )
        }

        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            throw NSError(
                domain: "AddModificationViewModel",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Could not process selected image."]
            )
        }

        // Decide the path (before/after) based on which image is being uploaded
        let pathSuffix: String
        if let beforeImage = self.beforeImage, image === beforeImage {
            pathSuffix = "before.jpg"
        } else {
            pathSuffix = "after.jpg"
        }

        let ref = storage.reference().child("modification_images/\(uid)/\(vehicleId)/\(modificationId)/\(pathSuffix)")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await ref.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await ref.downloadURL()

        return downloadURL.absoluteString
    }


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

