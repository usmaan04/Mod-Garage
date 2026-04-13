//
//  DVLAResponse.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 15/11/2025.
//

import Foundation

// A data model Used to map the JSON response from the DVLA VES API
struct DVLAResponseModel: Codable {
    let registrationNumber: String
    let make: String
    let colour: String
    let fuelType: String
    let yearOfManufacture: Int?
    
    // Fields for holding MOT details
    let motStatus: String?
    let motExpiryDate: String?

    // Fields for holding  tax details
    let taxStatus: String?
    let taxDueDate: String?

}
