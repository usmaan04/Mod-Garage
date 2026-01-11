//
//  VehicleDetailViewModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 10/01/2026.
//

import Foundation
import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth

@MainActor
class VehicleDetailViewModel: ObservableObject {
    
    @Published var isShowingAddModification = false
    @Published var isShowingAddFuelLog = false
    
    let modTypes = ["Exhaust", "Windows", "Lights", "Engine", "Bodykit"]
    
    @Published var modType: String = ""
    @Published var modName: String = ""
    @Published var modCost: Double = 0.00
    @Published var modDesc: String = ""
    
}
