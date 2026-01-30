//
//  ModificationModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 11/01/2026.
//

import Foundation
import PhotosUI

struct ModificationModel: Identifiable, Codable {
    var id: String
    var type: String
    var name: String
    var cost: Double
    var description: String?
    var date: Date
    var beforeImageURL: String?
    var afterImageURL: String?
    var createdAt: Date
}
