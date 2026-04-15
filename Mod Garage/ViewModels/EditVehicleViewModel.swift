import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

// Holds logic fo rupdating vehicle details
@MainActor
class EditVehicleViewModel: ObservableObject {
    @Published var model: String
    @Published var colour: String
    @Published var vehicle: VehicleModel

    // UI state management
    @Published var isSaving = false
    @Published var errorMessage: String?
    
    // Callback to close the view on success
    var onSaveSuccess: (() -> Void)?

    // Set values from fetched ones
    init(vehicle: VehicleModel) {
        self.vehicle = vehicle
        _model = Published(initialValue: vehicle.model)
        _colour = Published(initialValue: vehicle.colour)
    }
    
    // Determines if inputs are valid
    var isFormValid:  Bool {
        let trimmedModel = model.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedColour = colour.trimmingCharacters(in: .whitespacesAndNewlines)

        return !trimmedModel.isEmpty &&
                trimmedModel.count <= 20 &&
                !trimmedColour.isEmpty &&
                trimmedColour.count <= 10
    }

    // Validates data and updates users details
    func saveChanges() {
        
        // Run validation
        guard validateAndSetError() else { return }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not logged in"
            return
        }

        isSaving = true
        let db = Firestore.firestore()
        
        // Reference the specific document
        let vehicleRef = db.collection("users").document(userId).collection("vehicles").document(vehicle.id)
        
        // Prepare the update data
        let updatedData: [String: Any] = [
            "model": model.trimmingCharacters(in: .whitespacesAndNewlines),
            "colour": colour.trimmingCharacters(in: .whitespacesAndNewlines)
        ]
        
        // Perform the update
        vehicleRef.updateData(updatedData) { [weak self] error in
            DispatchQueue.main.async {
                self?.isSaving = false
                if let error = error {
                    self?.errorMessage = "Error updating vehicle: \(error.localizedDescription)"
                } else {
                    self?.errorMessage = nil
                    // Signal the View to close
                    self?.onSaveSuccess?()
                }
            }
        }
    }
    
    // Validates user entered/enterable fields
    func validateAndSetError() -> Bool{
        
        let trimmedModel = model.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedColour = colour.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Prevent empty model
        if trimmedModel.isEmpty {
            errorMessage = "Please confirm model name"
            return false
        }
        
        // Ensure name is not more than 20 characters
        if trimmedModel.count > 20 {
            errorMessage = "Model name must be 20 characters or fewer"
            return false
        }
        
        // Prevent empty colour
        if trimmedColour.isEmpty {
            errorMessage = "Please confirm colour"
            return false
        }
        
        // Ensure coloour is not more than 10 characters
        if trimmedColour.count > 10 {
            errorMessage = "Colour must be 10 characters or fewer"
        }
        
        errorMessage = nil
        return true
    }
}
