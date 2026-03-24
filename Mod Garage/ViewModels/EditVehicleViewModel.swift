import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore // 1. Import Firestore

@MainActor
class EditVehicleViewModel: ObservableObject {
    @Published var model: String
    @Published var colour: String
    @Published var vehicle: VehicleModel

    @Published var isSaving = false
    @Published var errorMessage: String?
    
    // Callback to close the view on success
    var onSaveSuccess: (() -> Void)?

    init(vehicle: VehicleModel) {
        self.vehicle = vehicle
        _model = Published(initialValue: vehicle.model)
        _colour = Published(initialValue: vehicle.colour)
    }

    var isFormValid: Bool {
        let trimmedModel = model.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedColour = colour.trimmingCharacters(in: .whitespacesAndNewlines)

        return !trimmedModel.isEmpty &&
               trimmedModel.count <= 20 &&
               !trimmedColour.isEmpty &&
               trimmedColour.count <= 10
    }

    func saveChanges() {
        guard validateAndSetError() else { return }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not logged in"
            return
        }

        isSaving = true
        let db = Firestore.firestore()
        
        // 2. Reference the specific document
        let vehicleRef = db.collection("users").document(userId).collection("vehicles").document(vehicle.id)
        
        // 3. Prepare the update data
        let updatedData: [String: Any] = [
            "model": model.trimmingCharacters(in: .whitespacesAndNewlines),
            "colour": colour.trimmingCharacters(in: .whitespacesAndNewlines)
        ]
        
        // 4. Perform the update
        vehicleRef.updateData(updatedData) { [weak self] error in
            DispatchQueue.main.async {
                self?.isSaving = false
                if let error = error {
                    self?.errorMessage = "Error updating vehicle: \(error.localizedDescription)"
                } else {
                    self?.errorMessage = nil
                    self?.onSaveSuccess?() // Signal the View to close
                }
            }
        }
    }

    func validateAndSetError() -> Bool {
        let trimmedModel = model.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedColour = colour.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedModel.isEmpty {
            errorMessage = "Please confirm model name"
            return false
        }
        if trimmedModel.count > 20 {
            errorMessage = "Model name must be 20 characters or fewer"
            return false
        }
        if trimmedColour.isEmpty {
            errorMessage = "Please confirm colour"
            return false
        }
        if trimmedColour.count > 10 {
            errorMessage = "Colour must be 10 characters or fewer"
        }

        errorMessage = nil
        return true
    }
}
