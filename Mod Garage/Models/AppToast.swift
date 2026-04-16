//
//  AppToast.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 15/04/2026.
//

import Foundation

// A data model representing a toastie notification
struct AppToast: Identifiable, Equatable {
    let id = UUID()
    let message: String
    let style: Style

    // Different types of notifications (succcess, failure or general info)
    enum Style {
        case success
        case error
        case info
    }
}
