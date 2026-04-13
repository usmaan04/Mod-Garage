//
//  NotificationManager.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 17/02/2026.
//


import Foundation
import UserNotifications

// Manages all communication between the app and the iPhone's notification center.
final class NotificationManager {
    
    // Single instance
    static let shared = NotificationManager()
    private init() {}

    // Asks the user for permission to show alerts, play sounds, and update the app icon badge
    func requestAuthorisation() async throws -> Bool {
        try await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])
    }

    // Checks if the user has allowed, denied, or not yet decided on notification permissions
    func notificationSettings() async -> UNNotificationSettings {
        await UNUserNotificationCenter.current().notificationSettings()
    }

    // Takes a Notification Request and schedules it to send
    func add(_ request: UNNotificationRequest) async throws {
        try await UNUserNotificationCenter.current().add(request)
    }

    // Cancels specific upcoming notifications using unique ID names
    func removePending(with identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    // Cancel all upcoming notification already scheduled
    func removeAllPending() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // Return a list of all notifications that are waiting to be shown
    func pendingRequests() async -> [UNNotificationRequest] {
        await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
}
