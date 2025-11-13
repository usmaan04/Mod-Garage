//
//  VehicleModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 12/11/2025.
//

import Foundation

struct VehicleModel: Identifiable, Codable {
    var id: String
    var userId: String
    var registration: String
    var make: String
    var model: String
    var colour: String
    var fuelType: String
    var motExpiryDate: Date?
    var motStatus: String?
    var taxExpiryDate: Date?
    var taxStatus: String?
    var createdAt: Date
}
