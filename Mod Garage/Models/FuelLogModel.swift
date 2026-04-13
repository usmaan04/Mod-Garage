//
//  FuelLogModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 17/01/2026.
//

import Foundation

// A data model representing a fuel purchase
// Maps directly to fuelLogs subcollection in Firestore
struct FuelLogModel: Identifiable, Codable {
    var id: String
    var location: String
    var litres: Double
    var pricePerLitre: Double
    var cost: Double
    var mileage: Int
    var date: Date
    var mpg: Double
    var createdAt: Date
}
