//
//  FuelViewModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 08/01/2026.
//

import Combine
import Foundation
import FirebaseAuth
import FirebaseFirestore

enum FuelTimeframe: String, CaseIterable, Identifiable {
    case oneMonth
    case sixMonths
    case oneYear
    case all

    // Required for SwiftUI ForEach
    var id: String { rawValue }

    // Display label for the UI pills
    var label: String {
        switch self {
        case .oneMonth: return "1M"
        case .sixMonths: return "6M"
        case .oneYear: return "1Y"
        case .all: return "All"
        }
    }

    // Start date used for filtering fuel logs.
    // `nil` means "no filtering" (All).
    func startDate(from now: Date = Date()) -> Date? {
        let calendar = Calendar.current

        switch self {
        case .oneMonth:
            return calendar.date(byAdding: .day, value: -30, to: now)

        case .sixMonths:
            return calendar.date(byAdding: .month, value: -6, to: now)

        case .oneYear:
            return calendar.date(byAdding: .year, value: -1, to: now)

        case .all:
            return nil
        }
    }
}

@MainActor
class FuelViewModel: ObservableObject {
    @Published var primaryVehicle: VehicleModel?
    @Published var fuelLogs: [FuelLogModel] = []

    // Timeframe selection (drives filtering, cards, charts)
    @Published var selectedTimeframe: FuelTimeframe = .oneMonth

    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    // Prevents repeated reloads
    private(set) var hasLoadedOnce = false

    private let db = Firestore.firestore()

    // filtered logs derived from selection
    var filteredLogs: [FuelLogModel] {
        guard let start = selectedTimeframe.startDate() else {
            return fuelLogs
        }
        return fuelLogs.filter { $0.date >= start }
    }

    // Summary for cards
    var totalSpending: Double {
        filteredLogs.reduce(0) { $0 + $1.cost }
    }

    /// Nil when there are no logs in the selected timeframe
    var averageMPG: Double? {
        guard !filteredLogs.isEmpty else { return nil }
        let total = filteredLogs.reduce(0) { $0 + $1.mpg }
        return total / Double(filteredLogs.count)
    }

    init() {
        // Provide a mock vehicle for previews/development when not logged in
        #if DEBUG
        if Auth.auth().currentUser == nil {
            self.primaryVehicle = VehicleModel(
                id: "veh_preview",
                userId: "user_preview",
                registration: "AB12 CDE",
                make: "Volkswagen",
                model: "Golf GTI",
                year: 2019,
                colour: "Red",
                fuelType: "Petrol",
                motExpiryDate: Calendar.current.date(byAdding: .day, value: 120, to: Date()),
                motStatus: "Valid",
                taxExpiryDate: Calendar.current.date(byAdding: .day, value: 90, to: Date()),
                taxStatus: "Taxed",
                imageURL: nil,
                isPrimary: true,
                createdAt: Date()
            )
        }
        #endif
    }

    // Call this from the view.
    // 1) load primary vehicle
    // 2) load fuel logs for that vehicle
    func loadFuelScreenData(force: Bool = false) async {
        if hasLoadedOnce && !force { return }

        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "No logged in user."
            primaryVehicle = nil
            fuelLogs = []
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            // Load primary vehicle
            let vehicleQuery = db
                .collection("users")
                .document(uid)
                .collection("vehicles")
                .whereField("isPrimary", isEqualTo: true)
                .limit(to: 1)

            let vehicleSnapshot = try await vehicleQuery.getDocuments()

            guard let vehicleDoc = vehicleSnapshot.documents.first else {
                primaryVehicle = nil
                fuelLogs = []
                hasLoadedOnce = true
                return
            }

            let vehicle = try vehicleDoc.data(as: VehicleModel.self)
            primaryVehicle = vehicle

            // Load fuel logs for that vehicle
            try await loadFuelLogsInternal(uid: uid, vehicleId: vehicle.id)

            hasLoadedOnce = true
        } catch {
            errorMessage = "Failed to load data: \(error.localizedDescription)"
            fuelLogs = []
        }
    }

    // Refresh Fuel Logs
    func refreshFuelLogs() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "No logged in user."
            fuelLogs = []
            return
        }
        guard let vehicle = primaryVehicle else {
            fuelLogs = []
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await loadFuelLogsInternal(uid: uid, vehicleId: vehicle.id)
        } catch {
            errorMessage = "Failed to load fuel logs: \(error.localizedDescription)"
            fuelLogs = []
        }
    }

    private func loadFuelLogsInternal(uid: String, vehicleId: String) async throws {
        let logsQuery = db
            .collection("users")
            .document(uid)
            .collection("vehicles")
            .document(vehicleId)
            .collection("fuelLogs")
            .order(by: "date", descending: true)
            .limit(to: 300)

        let logsSnapshot = try await logsQuery.getDocuments()

        let decoded: [FuelLogModel] = try logsSnapshot.documents.map { doc in
            try doc.data(as: FuelLogModel.self)
        }

        fuelLogs = decoded
    }
}
