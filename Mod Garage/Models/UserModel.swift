//
//  UserModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 10/11/2025.
//

import Foundation

struct UserModel: Identifiable, Codable {
    var id: String
    var name: String
    var email: String
    var profileImageURL: String?
    var vehicles: [VehicleModel]?
}
