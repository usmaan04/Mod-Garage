//
//  AddFuelLogViewModwl.swift
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

@MainActor
final class AddFuelLogViewModel: ObservableObject {

    let modTypes = ["Exhaust", "Windows", "Lights", "Engine", "Bodykit"]
    
    @Published var litres: Double = 0.0000 {
        didSet {
            pricePerLitre = litres == 0 ? 0 : cost / litres
        }
    }
    @Published var cost: Double = 0 {
        didSet {
            pricePerLitre = litres == 0 ? 0 : cost / litres
        }
    }
    @Published var pricePerLitre: Double = 0
    @Published var mileage: Int = 0
    @Published var date: Date = Date()
    @Published var mpg: Double?

    @Published var errorMessage: String? = nil

    // Called when the modification is ready to be saved to Firestore by the parent view
    var onFuelLogReady: ((FuelLogModel) -> Void)?

    func confirmFuelLog() async {
        errorMessage = nil

        // Validate
        if litres == 0 || cost  == 0 || mileage == 0 || date == Date() {
            errorMessage = "Please fill all fields"
            return
        }


        do {
            // Build model using URL strings (or nil)
            let newFuelLog = FuelLogModel(
                id: UUID().uuidString,
                litres: litres,
                pricePerLitre: cost / litres,
                cost: cost,
                mileage: mileage,
                date: date,    
                createdAt: Date()
            )

            // Send to parent to save into Firestore
            onFuelLogReady?(newFuelLog)

            resetView()
        } catch {
            errorMessage = "Failed to upload image(s): \(error.localizedDescription)"
        }
    }


    func resetView() {
        litres = 0.0000
        cost = 0
        mileage = 0
        date = Date()
        pricePerLitre = 0
        errorMessage = nil
    }
}
