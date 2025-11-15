//
//  DVLAResponse.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 15/11/2025.
//

import Foundation

struct DVLAResponse: Codable {
    let registrationNumber: String?
    let make: String?
    let model: String?
    let colour: String?
    let fuelType: String?
    
    let motExpiryDate: String?
    let motStatus: String?
    
    let taxDueDate: String?
    let taxStatus: String?
}
