//
//  AddFuelLogViewModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 17/01/2026.
//

import Foundation
import Combine
import SwiftUI
import FirebaseAuth
import FirebaseStorage
import PhotosUI

// Helper to round decimals
extension Double {
    func rounded(to places: Int) -> Double {
        let factor = pow(10, Double(places))
        return (self * factor).rounded() / factor
    }
}

@MainActor
final class AddFuelLogViewModel: ObservableObject {

    // Fields that the user fills out
    @Published var location: String = ""
    @Published var litres: Double = 0
    @Published var cost: Double = 0
    @Published private(set) var pricePerLitre: Double = 0
    @Published var mileage: Int = 0
    @Published var date: Date = Date()

    // Efficiency data calculated by the system
    @Published var mpg: Double = 0
    @Published var previousMileage: Int? = nil
    
    @Published var showDatePicker = false
    @Published var errorMessage: String? = nil
    var savedLog: FuelLogModel? = nil

    init() {
        // Listens to cost and litres and updates pricePerLitre whenever they change
        Publishers.CombineLatest($cost, $litres)
            .map { cost, litres -> Double in
                guard litres != 0 else { return 0 }
                return (cost / litres).rounded(to: 3)
            }
            .assign(to: &$pricePerLitre)
    }

    // Callback to tell parent view that log is ready to be saved
    var onFuelLogReady: ((FuelLogModel) -> Void)?
    
    // Validates user entered/enterable fields
    func isFormValid() -> Bool{
        
        errorMessage = nil
        
        // Prevent empty fields
        if location.isEmpty || litres == 0 || cost == 0 || mileage == 0 {
            errorMessage = "Please fill in all fields"
            return false
        }
        
        // Ensure location is not more than 25 characters
        if location.count > 25 {
            errorMessage = "Please entar a shorter name for the location"
            return false
        }
        
        return true
    }

    // Called when user presses save, creates fuel log model
    func confirmFuelLog() async {

        // Check form validation
        guard isFormValid() else { return }

        // Calculate mpg (distance / litres converted to gallons) using previous mileage
        if let prev = previousMileage {
            let distance = mileage - prev
            guard distance > 0 else {
                errorMessage = "Mileage must be greater than the previous fuel log mileage (\(prev))."
                return
            }
            mpg = (Double(distance) / (litres / 4.546) ).rounded(to: 2)
        } else {
            // Can't calculate MPG on the first log
            mpg = 0
        }

        // Create the fuel log model using the inputted and calculated values
        do {
            let newFuelLog = FuelLogModel(
                id: UUID().uuidString,
                location: location,
                litres: litres,
                pricePerLitre: pricePerLitre,
                cost: cost,
                mileage: mileage,
                date: date,
                mpg: mpg,
                createdAt: Date()
            )

            // Set onFuelLogReady for saving
            onFuelLogReady?(newFuelLog)
            
            // Set saved log for testing
            savedLog = newFuelLog
            
            resetView()
            
        } catch {
            errorMessage = "Failed to save fuel log"
        }
    }
    
    // Reset all fields back to default
    func resetView() {
        location = ""
        litres = 0
        cost = 0
        mileage = 0
        date = Date()
        pricePerLitre = 0
        mpg = 0
        errorMessage = nil
    }
}
