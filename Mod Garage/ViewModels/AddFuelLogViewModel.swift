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

extension Double {
    func rounded(to places: Int) -> Double {
        let factor = pow(10, Double(places))
        return (self * factor).rounded() / factor
    }
}

@MainActor
final class AddFuelLogViewModel: ObservableObject {

    let modTypes = ["Exhaust", "Windows", "Lights", "Engine", "Bodykit"]

    @Published var location: String = ""
    @Published var litres: Double = 0
    @Published var cost: Double = 0
    @Published private(set) var pricePerLitre: Double = 0
    @Published var mileage: Int = 0
    @Published var date: Date = Date()
    var savedLog: FuelLogModel? = nil

    // Calculated as (miles driven since last fill) / litres / 4.456 filled
    @Published var mpg: Double = 0

    // Set this from the parent view (latest/previous fuel log mileage)
    @Published var previousMileage: Int? = nil
    
    @Published var showDatePicker = false
    @Published var errorMessage: String? = nil
    
    private let storage = Storage.storage()

    init() {
        Publishers.CombineLatest($cost, $litres)
            .map { cost, litres -> Double in
                guard litres != 0 else { return 0 }
                return (cost / litres).rounded(to: 3)
            }
            .assign(to: &$pricePerLitre)
    }

    // Called when the modification is ready to be saved to Firestore by the parent view
    var onFuelLogReady: ((FuelLogModel) -> Void)?
    
    func isFormValid() -> Bool{
        
        errorMessage = nil
        
        // Validate basic fields
        if location.isEmpty || litres == 0 || cost == 0 || mileage == 0 {
            errorMessage = "Please fill in all fields"
            return false
        }
        
        // Validate basic fields
        if location.count > 25 {
            errorMessage = "Please entar a shorter name for the location"
            return false
        }
        
        return true
    }

    func confirmFuelLog() async {

        // Validate form
        guard isFormValid() else {
            return
        }

        // Compute mpg (distance / litres) using previous mileage
        if let prev = previousMileage {
            let distance = mileage - prev
            guard distance > 0 else {
                errorMessage = "Mileage must be greater than the previous fuel log mileage (\(prev))."
                return
            }
            mpg = (Double(distance) / (litres / 4.546) ).rounded(to: 2)
        } else {
            // No previous log so can't calculate mpg yet
            mpg = 0
        }

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

            onFuelLogReady?(newFuelLog)
            savedLog = newFuelLog
            resetView()
        } catch {
            errorMessage = "Failed to save fuel log: \(error.localizedDescription)"
        }
    }

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
