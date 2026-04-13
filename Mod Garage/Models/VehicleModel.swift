//
//  VehicleModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 12/11/2025.
//

import Foundation

// A data model representing a vehicle owned by a user
// Maps directly to users collection in Firestore
struct VehicleModel: Identifiable, Codable {
    var id: String
    var userId: String
    var registration: String
    var make: String
    var model: String
    var year: Int
    var colour: String
    var fuelType: String
    var motExpiryDate: Date?
    var motStatus: String?
    var taxExpiryDate: Date?
    var taxStatus: String?
    var imageURL: String?
    var isPrimary: Bool
    var createdAt: Date
}
