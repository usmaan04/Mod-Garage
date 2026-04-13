//
//  NotificationKeys.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 17/02/2026.
//

import Foundation

// An enumeration of the two types of reminders
enum ReminderType: String {
    case mot
    case tax
}

// Collection of static keys used for AppStorage and notification identification
enum NotificationKeys {
    // Prefix used to only identify the app's notification requests
    static let idPrefix = "mg"

    // AppStorage keys
    static let needsSync = "notificationsNeedSync"

    // Flags to determine if the user has opted into specific reminder types
    static let motEnabled = "motRemindersEnabled"
    static let taxEnabled = "taxRemindersEnabled"

    // CSV strings storing the user's chosen lead times
    static let motLeadCSV = "motLeadDaysCSV"
    static let taxLeadCSV = "taxLeadDaysCSV"

    // Preferred time of day for sending notifications
    static let hour = "reminderHour"
    static let minute = "reminderMinute"
}

// Logic for converting between arrays of days and storage-friendly CSV strings
enum LeadDays {
    static let defaultCSV = "30,7,1"

    // Converts a CSV string into a sorted array of Integers
    static func parse(_ csv: String) -> [Int] {
        csv.split(separator: ",")
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            .filter { $0 > 0 }
            .sorted(by: >)
    }

    // Sanitises and converts an array of lead days back into a CSV string for AppStorage
    static func toCSV(_ days: [Int]) -> String {
        Array(Set(days))
            .filter { $0 > 0 }
            .sorted(by: >)
            .map(String.init)
            .joined(separator: ",")
    }
}
