//
//  Tab.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 11/11/2025.
//

import Foundation

enum Tab: String, CaseIterable, Identifiable {
    case home = "house"
    case vehicle = "car"
    case add = "plus"
    case fuel = "fuelpump"
    case settings = "gear"
    var id: String { rawValue }
}
