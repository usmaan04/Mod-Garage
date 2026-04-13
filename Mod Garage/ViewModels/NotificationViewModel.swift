//
//  NotificationViewModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 17/02/2026.
//


import SwiftUI
import Combine
import UserNotifications

enum NotificationPermissionState {
    case notDetermined
    case denied
    case authorized
}
@MainActor
final class NotificationViewModel: ObservableObject {

    // MARK: - UI State
    @Published var permissionState: NotificationPermissionState = .notDetermined
    @Published var hasPermission: Bool = false
    @Published var isSyncing: Bool = false
    @Published var statusMessage: String? = nil

    // MARK: - Preferences (Global v1)
    @AppStorage(NotificationKeys.motEnabled) var motEnabled: Bool = true
    @AppStorage(NotificationKeys.taxEnabled) var taxEnabled: Bool = true

    @AppStorage(NotificationKeys.motLeadCSV) private var motLeadCSV: String = LeadDays.defaultCSV
    @AppStorage(NotificationKeys.taxLeadCSV) private var taxLeadCSV: String = LeadDays.defaultCSV

    @AppStorage(NotificationKeys.hour) var reminderHour: Int = 9
    @AppStorage(NotificationKeys.minute) var reminderMinute: Int = 0

    // Flag set elsewhere when vehicles change (add/edit/delete)
    @AppStorage(NotificationKeys.needsSync) var needsSync: Bool = false

    private let manager: NotificationManager
    private let vehicleProvider: () -> [VehicleModel]

    init(
        manager: NotificationManager = .shared,
        vehicleProvider: @escaping () -> [VehicleModel]
    ) {
        self.manager = manager
        self.vehicleProvider = vehicleProvider
    }

    // MARK: - Lead days (for UI)
    var motLeadDays: [Int] { LeadDays.parse(motLeadCSV) }
    var taxLeadDays: [Int] { LeadDays.parse(taxLeadCSV) }

    func updateMotLeadDays(_ new: [Int]) {
        motLeadCSV = LeadDays.toCSV(new)
        needsSync = true
    }

    func updateTaxLeadDays(_ new: [Int]) {
        taxLeadCSV = LeadDays.toCSV(new)
        needsSync = true
    }

    // MARK: - Permission

    func refreshPermission() async {
        let s = await manager.notificationSettings()

        switch s.authorizationStatus {
        case .notDetermined:
            permissionState = .notDetermined
            hasPermission = false

        case .denied:
            permissionState = .denied
            hasPermission = false

        case .authorized, .provisional, .ephemeral:
            permissionState = .authorized

            let canAlert =
                s.alertSetting == .enabled ||
                s.lockScreenSetting == .enabled ||
                s.notificationCenterSetting == .enabled

            hasPermission = canAlert

        @unknown default:
            permissionState = .denied
            hasPermission = false
        }
    }

    func requestPermission() async {
        let s = await manager.notificationSettings()

        switch s.authorizationStatus {
        case .notDetermined:
            do {
                _ = try await manager.requestAuthorisation()
                try? await Task.sleep(nanoseconds: 300_000_000)
                await refreshPermission()
            } catch {
                statusMessage = "Permission request failed: \(error.localizedDescription)"
            }

        case .denied:
            statusMessage = "Notifications are disabled for Mod Garage. Enable them in iOS Settings."
            // (UI should offer an "Open iOS Settings" button)

        case .authorized, .provisional, .ephemeral:
            // User may have turned off banners/lockscreen etc.
            await refreshPermission()
            if !hasPermission {
                statusMessage = "Notifications are enabled, but alerts are turned off. Turn on Lock Screen / Banners in iOS Settings."
            } else {
                statusMessage = "Notifications are already enabled."
            }

        @unknown default:
            statusMessage = "Unknown notification permission state."
        }
    }

    // MARK: - Lifecycle

    func onOpen() async {
        await refreshPermission()

        if needsSync {
            await syncAll()
            needsSync = false
        }
    }

    // MARK: - Sync

    func syncAll() async {
        isSyncing = true
        defer { isSyncing = false }

        await refreshPermission()
        guard hasPermission else {
            statusMessage = "Notifications are off. Enable them in iOS Settings"
            return
        }

        // Build the notifications we want
        let vehicles = vehicleProvider()
        let requests = buildRequests(for: vehicles)
        
        guard !requests.isEmpty else {
            statusMessage = "No upcoming reminders to schedule. Check expiry dates + lead times + time of day"
            return
        }

        // Remove only our reminders, then add new
        await removeOurPendingRequests()

        do {
            for r in requests {
                try await manager.add(r)
            }
            statusMessage = "Scheduled \(requests.count) reminder\(requests.count == 1 ? "" : "s")."
        } catch {
            statusMessage = "Failed to schedule: \(error.localizedDescription)"
        }
    }

    func clearAllReminders() async {
        await removeOurPendingRequests()
        statusMessage = "Cleared all reminders"
        needsSync = false
    }

    // MARK: - Internals

    private func removeOurPendingRequests() async {
        let pending = await manager.pendingRequests()
        let ourPrefix = "\(NotificationKeys.idPrefix)_"

        let ids = pending.map(\.identifier).filter { $0.hasPrefix(ourPrefix) }
        if !ids.isEmpty {
            manager.removePending(with: ids)
        }
    }

    private func buildRequests(for vehicles: [VehicleModel]) -> [UNNotificationRequest] {
        var out: [UNNotificationRequest] = []

        for v in vehicles {
            if motEnabled, let motDate = v.motExpiryDate {
                out += build(type: .mot, vehicle: v, expiry: motDate, leadDays: motLeadDays)
            }
            if taxEnabled, let taxDate = v.taxExpiryDate {
                out += build(type: .tax, vehicle: v, expiry: taxDate, leadDays: taxLeadDays)
            }
        }

        return out
    }

    private func build(
        type: ReminderType,
        vehicle: VehicleModel,
        expiry: Date,
        leadDays: [Int]
    ) -> [UNNotificationRequest] {

        let calendar = Calendar.current
        var out: [UNNotificationRequest] = []

        for days in leadDays {
            guard let baseDate = calendar.date(byAdding: .day, value: -days, to: expiry) else { continue }

            var comps = calendar.dateComponents([.year, .month, .day], from: baseDate)
            comps.hour = reminderHour
            comps.minute = reminderMinute

            guard let scheduledDate = calendar.date(from: comps) else { continue }
            guard scheduledDate > Date() else { continue }

            let content = UNMutableNotificationContent()
            content.sound = .default

            let carName = "\(vehicle.make) \(vehicle.model)"
            let reg = vehicle.registration

            switch type {
            case .mot:
                content.title = "MOT reminder"
                content.body = "MOT for \(carName) (\(reg)) expires in \(days) day\(days == 1 ? "" : "s")"
            case .tax:
                content.title = "Tax reminder"
                content.body = "Tax for \(carName) (\(reg)) expires in \(days) day\(days == 1 ? "" : "s")"
            }

            let id = "\(NotificationKeys.idPrefix)_\(type.rawValue)_\(vehicle.id)_\(days)"

            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            out.append(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
        }

        return out
    }
}
