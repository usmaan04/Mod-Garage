//
//  FuelLogModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 17/01/2026.
//

import Foundation

struct FuelLogModel: Identifiable, Codable {
    var id: String
    var litres: Double
    var pricePerLitre: Double
    var cost: Double
    var mileage: Int
    var date: Date
    var mpg: Double
    var createdAt: Date
}
