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
    @Published var beforeImage: PhotosPickerItem?
    @Published var afterImage: PhotosPickerItem?

    @Published var errorMessage: String? = nil

    // Called when the modification is ready to be saved to Firestore by the parent view
    var onModificationReady: ((ModificationModel) -> Void)?

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

        do {
            // Upload images (if provided) and get download URLs
            //let beforeURL = try await uploadPickedImage(beforeImage, uid: uid, folder: "before")
            //let afterURL  = try await uploadPickedImage(afterImage, uid: uid, folder: "after")

            // Build model using URL strings (or nil)
            let newModification = ModificationModel(
                id: UUID().uuidString,
                type: modType,
                name: modName,
                cost: modCost,
                description: modDesc,
                beforeImageURL: nil,     // String?
                afterImageURL: nil,       // String?
                createdAt: Date()
            )

            // Send to parent to save into Firestore
            onModificationReady?(newModification)

            resetView()
        } catch {
            errorMessage = "Failed to upload image(s): \(error.localizedDescription)"
        }
    }


    func resetView() {
        modType = "Select Type"
        modName = ""
        modCost = 0
        modDesc = ""
        beforeImage = nil
        afterImage = nil
        errorMessage = nil
    }
}
