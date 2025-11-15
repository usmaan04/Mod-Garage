//
//  DVLAResponse.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 15/11/2025.
//

import Foundation

struct DVLAResponseModel: Codable {
    let registrationNumber: String
    let make: String
    let colour: String
    let fuelType: String
    let yearOfManufacture: Int?
    
    let motStatus: String?
    let motExpiryDate: String?

    let taxStatus: String?
    let taxDueDate: String?

}
