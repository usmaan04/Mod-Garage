//
//  DVLAResponse.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 15/11/2025.
//

import Foundation

/// A placeholder response model for DVLA vehicle lookup.
/// Replace properties with the real API schema when available.
struct DVLAResponse: Codable, Sendable, Equatable {
    var registration: String
    var make: String?
    var model: String?
    var color: String?
    var yearOfManufacture: Int?
}
