//
//  NotificationKeys.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 17/02/2026.
//


import Foundation

enum ReminderType: String {
    case mot
    case tax
}

enum NotificationKeys {
    // Prefix so we only touch our app’s reminders
    static let idPrefix = "mg"

    // AppStorage keys
    static let needsSync = "notificationsNeedSync"

    static let motEnabled = "motRemindersEnabled"
    static let taxEnabled = "taxRemindersEnabled"

    static let motLeadCSV = "motLeadDaysCSV"
    static let taxLeadCSV = "taxLeadDaysCSV"

    static let hour = "reminderHour"
    static let minute = "reminderMinute"
}

enum LeadDays {
    static let defaultCSV = "30,7,1"

    static func parse(_ csv: String) -> [Int] {
        csv.split(separator: ",")
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            .filter { $0 > 0 }
            .sorted(by: >)
    }

    static func toCSV(_ days: [Int]) -> String {
        Array(Set(days))
            .filter { $0 > 0 }
            .sorted(by: >)
            .map(String.init)
            .joined(separator: ",")
    }
}
