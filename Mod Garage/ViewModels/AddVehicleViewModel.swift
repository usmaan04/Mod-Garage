//
//  AddVehicleViewModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 15/11/2025.
//




import Foundation
import SwiftUI
import Combine

@MainActor
class AddVehicleViewModel: ObservableObject {
    @Published var registration: String = ""
    @Published var isLoading: Bool = false
    @Published var dvlaVehicle: DVLAResponseModel? = nil
    @Published var errorMessage: String? = nil

    func searchRegistration() {
        // Prevent spaces or empty inputs
        guard !registration.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        self.isLoading = true
        self.errorMessage = nil
        self.dvlaVehicle = nil

        Task {
            do {
                let result = try await DVLAService().fetchVehicle(for: registration)
                self.dvlaVehicle = result
                print(result)
            } catch {
                self.errorMessage = "Could not find vehicle. Please check the registration."
            }

            self.isLoading = false
        }
    }
    
    func confirmVehicle(){
        print("I confirm")
    }
}
