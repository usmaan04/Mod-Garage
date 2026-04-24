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

// Represents the different timeframe to filter fuel information by
enum FuelTimeframe: String, CaseIterable, Identifiable {
    case oneMonth
    case sixMonths
    case oneYear
    case all

    // Required for SwiftUI ForEach
    var id: String { rawValue }

    // UI Labels
    var label: String {
        switch self {
        case .oneMonth: return "1M"
        case .sixMonths: return "6M"
        case .oneYear: return "1Y"
        case .all: return "6Y"
        }
    }

    // Logic to calculate cutoff dates
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
            return calendar.date(byAdding: .year, value: -6, to: now)
        }
    }
    
    // Helpers to move timeframe through swiping
    var next: FuelTimeframe? {
        let all = Self.allCases
        guard let index = all.firstIndex(of: self), index < all.count - 1 else {
            return nil
        }
        return all[index + 1]
    }
    
    var previous: FuelTimeframe? {
        let all = Self.allCases
        guard let index = all.firstIndex(of: self), index > 0 else {
            return nil
        }
        return all[index - 1]
    }
    
}

// Foramts strings into currency
private func currencyString(from value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "GBP"
    return formatter.string(from: NSNumber(value: value)) ?? "£0.00"
}
private func spendingCurrencyString(from value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "GBP"
    formatter.maximumFractionDigits = 0
    formatter.minimumFractionDigits = 0
    return formatter.string(from: NSNumber(value: value)) ?? "£0.00"
}

// Data structures for the Swift Charts
struct MPGChartPoint: Identifiable {
    let id: String
    let x: Date
    let avgMPG: Double
}
struct SpendChartPoint: Identifiable {
    let id: String
    let x: Date
    let totalSpend: Double
}

// Calculate the midpoint to center markers
extension Calendar {
    func startOfDayLocal(_ date: Date) -> Date {
            var c = self
            c.timeZone = .current
            return c.startOfDay(for: date)
    }

    func endOfDayLocal(_ date: Date) -> Date {
        var c = self
        c.timeZone = .current
        let start = c.startOfDay(for: date)
        return c.date(byAdding: .second, value: 86399, to: start)! // 23:59:59
    }

    func startOfMonth(for date: Date) -> Date {
        self.date(from: dateComponents([.year, .month], from: date))!
    }

    func endOfMonth(for date: Date) -> Date {
        let start = startOfMonth(for: date)
        let next = self.date(byAdding: .month, value: 1, to: start)!
        return self.date(byAdding: .day, value: -1, to: next)!
    }
    func midOfMonth(for date: Date) -> Date {
        let start = startOfMonth(for: date)
        let days = range(of: .day, in: .month, for: start)!.count
        return self.date(byAdding: .day, value: days / 2, to: start)!
    }

    func midOfYear(for date: Date) -> Date {
        let start = self.date(from: DateComponents(
            year: component(.year, from: date),
            month: 1,
            day: 1
        ))!
        return self.date(byAdding: .month, value: 6, to: start)!
    }
}

// Handles the main logic to display fuel data
@MainActor
class FuelViewModel: ObservableObject {
    @Published var primaryVehicle: VehicleModel?
    @Published var fuelLogs: [FuelLogModel] = []
    
    //Used to display sepcifc tappable chart points
    @Published var selectedMPGPoint: MPGChartPoint? = nil
    @Published var selectedSpendPoint: SpendChartPoint? = nil

    @Published var isShowingAddFuelLog = false
    @Published var isShowingAllLogs = false
 
    // Timeframe selection (drives filtering, cards, charts)
    @Published var selectedTimeframe: FuelTimeframe = .oneMonth

    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private(set) var hasLoadedOnce = false
    private let db = Firestore.firestore()
    
    // Finds the latest log date to anchor charts correctly
    private var chartAnchorDate: Date {
        let now = Date()
        let latestLogDate = fuelLogs.map(\.date).max() ?? now
        return max(now, latestLogDate)
    }
    
    // Gets the highest fuel log odometer/mileage value
    var latestFuelLogMileage: Int? {
        fuelLogs.max(by: { $0.mileage < $1.mileage })?.mileage
    }

    // Shhows averages or the selected point value
    var mpgHeaderText: Double {
        if let selected = selectedMPGPoint { return selected.avgMPG }
        return averageMPG ?? 0
    }
    
    var spendingHeaderText: String {
        if let selected = selectedSpendPoint { return spendingCurrencyString(from: selected.totalSpend) }
        return currencyString(from: totalSpending)
    }

    // Filters logs based on the timeframe
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

    // Nil when there are no logs in the selected timeframe
    var averageMPG: Double? {
        guard !filteredLogs.isEmpty else { return nil }
        let total = filteredLogs.reduce(0) { $0 + $1.mpg }
        return total / Double(filteredLogs.count)
    }
    
    // MARK: - Chart data mapping
    // Switches the logic based on the timeframe
    var mpgChartPoints: [MPGChartPoint] {
        switch selectedTimeframe {
        case .oneMonth:
            return dailyMPGPointsForCurrentMonth()
        case .sixMonths, .oneYear:
            return monthlyMPGPoints()
        case .all:
            return yearlyMPGPoints()
        }
    }
    
    var spendChartPoints: [SpendChartPoint] {
        switch selectedTimeframe {
        case .oneMonth:
            return dailySpendPointsForAnchorMonth()
        case .sixMonths, .oneYear:
            return monthlySpendPointsForTimeframe()
        case .all:
            return yearlySpendPoints()
        }
    }
    
    // Generates x axis for 1 month timeframe, shows 1 and then every 5 days
    func dayTicksForAnchorMonth(startAtDay: Int = 1, step: Int = 5) -> [Date] {
        var cal = Calendar.current
        cal.timeZone = .current

        let anchor = chartAnchorDate
        let monthStart = cal.startOfMonth(for: anchor)

        let daysInMonth = cal.range(of: .day, in: .month, for: monthStart)?.count ?? 30

        var ticks: [Date] = []

        // Always include day 1
        let day1 = cal.date(byAdding: .day, value: 0, to: monthStart)!
        ticks.append(day1)

        // Then include multiples of 5 up to the last day in month
        var d = 5
        while d <= daysInMonth {
            let date = cal.date(byAdding: .day, value: d - 1, to: monthStart)!
            ticks.append(date)
            d += 5
        }

        return ticks
    }
    
    // Calculates the domain for the MPG chart X axis
    var chartDomain: ClosedRange<Date>? {
        let cal = Calendar.current
        let anchor = chartAnchorDate

        switch selectedTimeframe {
        case .oneMonth:
            let start = cal.startOfMonth(for: anchor)
            let next = cal.date(byAdding: .day, value: 31, to: start)!
            let end = cal.date(byAdding: .second, value: -31, to: next)!
            return start...end

        case .sixMonths:
            let start = cal.date(byAdding: .month, value: -5, to: cal.startOfMonth(for: anchor))!
            let end = cal.date(byAdding: .month, value: 1, to: cal.startOfMonth(for: anchor))!
            return start...end

        case .oneYear:
            let start = cal.date(byAdding: .month, value: -11, to: cal.startOfMonth(for: anchor))!
            let end = cal.date(byAdding: .month, value: 1, to: cal.startOfMonth(for: anchor))!
            return start...end
            
        case .all:
            let anchorYear = cal.component(.year, from: anchor)
            let start = cal.date(from: DateComponents(year: anchorYear - 5, month: 1, day: 1))!
            let end = cal.date(from: DateComponents(year: anchorYear + 1, month: 1, day: 1))!
            return start...end
        }
    }
    
    // Formats dates into months or days
    func monthString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMM"
        return formatter.string(from: date).uppercased()
    }
    func dayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    // Determines the values to display MPG per day
    private func dailyMPGPointsForCurrentMonth() -> [MPGChartPoint] {
        var cal = Calendar.current
        cal.timeZone = .current

        let now = Date()

        let monthStart = cal.startOfMonth(for: now)
        let nextMonthStart = cal.date(byAdding: .month, value: 1, to: monthStart)!

        // Only logs in the CURRENT calendar month (in local time)
        let monthLogs = filteredLogs.filter { log in
            let localDay = cal.startOfDay(for: log.date)
            return localDay >= monthStart && localDay < nextMonthStart
        }

        // Group by local day (startOfDay)
        let grouped = Dictionary(grouping: monthLogs) { log in
            cal.startOfDay(for: log.date)
        }

        var points: [MPGChartPoint] = grouped.compactMap { (dayStart, logs) in
            guard !logs.isEmpty else { return nil }

            let avg = logs.reduce(0) { $0 + $1.mpg } / Double(logs.count)

            let midday = cal.date(bySettingHour: 12, minute: 0, second: 0, of: dayStart) ?? dayStart

            let id = ISO8601DateFormatter().string(from: dayStart)

            return MPGChartPoint(id: id, x: midday, avgMPG: avg)
        }

        points.sort { $0.x < $1.x }
        return points
    }
    
    // Determines the values to display spending per day
    private func dailySpendPointsForAnchorMonth() -> [SpendChartPoint] {
        var cal = Calendar.current
        cal.timeZone = .current

        let anchor = chartAnchorDate
        let monthStart = cal.startOfMonth(for: anchor)
        let nextMonthStart = cal.date(byAdding: .month, value: 1, to: monthStart)!

        // only logs inside anchor month in local time
        let monthLogs = filteredLogs.filter { log in
            let day = cal.startOfDay(for: log.date)
            return day >= monthStart && day < nextMonthStart
        }

        // group by local startOfDay
        let grouped = Dictionary(grouping: monthLogs) { log in
            cal.startOfDay(for: log.date)
        }

        var points: [SpendChartPoint] = grouped.compactMap { (dayStart, logs) in
            guard !logs.isEmpty else { return nil }
            let total = logs.reduce(0) { $0 + $1.cost }

            // plot at midday to avoid timezone drift
            let x = cal.date(bySettingHour: 12, minute: 0, second: 0, of: dayStart) ?? dayStart
            let id = ISO8601DateFormatter().string(from: dayStart)
            return SpendChartPoint(id: id, x: x, totalSpend: total)
        }

        points.sort { $0.x < $1.x }
        return points
    }

    // Determines the values to display MPG per month
    private func monthlyMPGPoints() -> [MPGChartPoint] {
        let grouped = Dictionary(grouping: filteredLogs) { log in
            monthId(for: log.date) // "YYYY-MM"
        }
        
        let cal = Calendar.current

        var points: [MPGChartPoint] = grouped.compactMap { (id, logs) in
            guard let monthStart = monthStart(from: id), !logs.isEmpty else { return nil }
            let avg = logs.reduce(0) { $0 + $1.mpg } / Double(logs.count)
            let midMonth = cal.midOfMonth(for: monthStart)
            return MPGChartPoint(id: id, x: midMonth, avgMPG: avg)
        }

        points.sort { $0.x < $1.x }
        return points
    }
    
    // Determines the values to display spending per month
    private func monthlySpendPointsForTimeframe() -> [SpendChartPoint] {
        let grouped = Dictionary(grouping: filteredLogs) { log in
            monthId(for: log.date) // "YYYY-MM"
        }

        let cal = Calendar.current

        var points: [SpendChartPoint] = grouped.compactMap { (id, logs) in
            guard let start = monthStart(from: id), !logs.isEmpty else { return nil }
            let total = logs.reduce(0) { $0 + $1.cost }
            let x = cal.midOfMonth(for: start) 
            return SpendChartPoint(id: id, x: x, totalSpend: total)
        }

        points.sort { $0.x < $1.x }
        return points
    }

    // Determines the values to display MPG per year
    private func yearlyMPGPoints() -> [MPGChartPoint] {
        let grouped = Dictionary(grouping: filteredLogs) { log in
            yearId(for: log.date) // "YYYY"
        }
        
        let cal = Calendar.current

        var points: [MPGChartPoint] = grouped.compactMap { (id, logs) in
            guard let yearStart = yearStart(from: id), !logs.isEmpty else { return nil }
            let avg = logs.reduce(0) { $0 + $1.mpg } / Double(logs.count)
            let midYear = cal.midOfYear(for: yearStart)
            return MPGChartPoint(id: id, x: midYear, avgMPG: avg)
        }

        points.sort { $0.x < $1.x }
        return points
    }
    
    // Determines the values to display spending per year
    private func yearlySpendPoints() -> [SpendChartPoint] {
        let grouped = Dictionary(grouping: filteredLogs) { log in
            yearId(for: log.date)
        }

        let cal = Calendar.current

        var points: [SpendChartPoint] = grouped.compactMap { (id, logs) in
            guard let start = yearStart(from: id), !logs.isEmpty else { return nil }
            let total = logs.reduce(0) { $0 + $1.cost }
            let x = cal.midOfYear(for: start) // ✅ centered in year column
            return SpendChartPoint(id: id, x: x, totalSpend: total)
        }

        points.sort { $0.x < $1.x }
        return points
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

    // MARK: - Firebase Logic
    // Retrieves all fuel logs from Firestore
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
    
    // Add a new fuel log
    func addFuelLog(_ fuelLog: FuelLogModel, vehicleId: String) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "No logged in user."
            return
        }

        let logsCollection = db
            .collection("users")
            .document(uid)
            .collection("vehicles")
            .document(vehicleId)
            .collection("fuelLogs")

        do {
            try logsCollection.addDocument(from: fuelLog)
            await refreshFuelLogs()
            isShowingAddFuelLog = false
        } catch {
            errorMessage = "Failed to save fuel log: \(error.localizedDescription)"
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

    // Load the latest 300 fuel logs
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
    
    private func monthId(for date: Date) -> String {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month], from: date)
        let year = comps.year ?? 0
        let month = comps.month ?? 1
        return String(format: "%04d-%02d", year, month)
    }

    private func monthStart(from id: String) -> Date? {
        let parts = id.split(separator: "-")
        guard parts.count == 2,
              let year = Int(parts[0]),
              let month = Int(parts[1]) else { return nil }
        return Calendar.current.date(from: DateComponents(year: year, month: month, day: 1))
    }

    private func dayId(for date: Date) -> String {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        let y = comps.year ?? 0
        let m = comps.month ?? 1
        let d = comps.day ?? 1
        return String(format: "%04d-%02d-%02d", y, m, d)
    }

    private func dayStart(from id: String) -> Date? {
        let parts = id.split(separator: "-")
        guard parts.count == 3,
              let year = Int(parts[0]),
              let month = Int(parts[1]),
              let day = Int(parts[2]) else { return nil }
        return Calendar.current.date(from: DateComponents(year: year, month: month, day: day))
    }

    private func yearId(for date: Date) -> String {
        let year = Calendar.current.component(.year, from: date)
        return String(format: "%04d", year)
    }

    private func yearStart(from id: String) -> Date? {
        guard let year = Int(id) else { return nil }
        return Calendar.current.date(from: DateComponents(year: year, month: 1, day: 1))
    }


}

