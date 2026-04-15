//
//  Tab.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 11/11/2025.
//

import Foundation

// An enumeration representing a tab in the global navigation bar
enum Tab: String, CaseIterable, Identifiable {
    case home = "house"
    case vehicle = "car"
    case add = "plus"
    case fuel = "fuelpump"
    case settings = "gear"
    
    // Needed by Identifiable for iteration in View
    var id: String { rawValue }
}
