//
//  HomeViewModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 10/11/2025.
//

import Combine
import Foundation
import FirebaseAuth
import FirebaseFirestore


enum ActivityItem: Identifiable {
    case modification(ModificationModel)
    case fuel(FuelLogModel)

    var id: String {
        switch self {
        case .modification(let m):
            // Prefer a stable Firestore docId on your model if you have it.
            return "mod-\(m.id)"
        case .fuel(let f):
            return "fuel-\(f.id)"
        }
    }

    var sortDate: Date {
        switch self {
        case .modification(let m):
            // Use createdAt if you want "added recently", or date if "installed date"
            return m.date
        case .fuel(let f):
            return f.date
        }
    }
}

enum QuickAddAction: Identifiable {
    case modification
    case fuelLog

    var id: String {
        switch self {
        case .modification: return "modification"
        case .fuelLog: return "fuelLog"
        }
    }
}

@MainActor
class HomeViewModel: ObservableObject {
    @Published var profilePhotoURL: URL?
    @Published var name: String = ""
    @Published var isProfileLoading = true
    @Published var selectedTab: Tab = .home
    @Published var primaryVehicle : VehicleModel?
    @Published var modifications: [ModificationModel] = []
    @Published var fuelLogs: [FuelLogModel] = []
    @Published var recentActivity: [ActivityItem] = []
    
    @Published var selectedQuickAction: QuickAddAction? = nil
    @Published var isShowingQuickAddMenu = false
    @Published var isShowingAllMods = false
    @Published var isShowingAllLogs = false
    
    @Published var isLoading = false
    @Published var showNotifications = false
    @Published var errorMessage: String? = nil
    
    var latestFuelLogMileage: Int? {
        fuelLogs.max(by: { $0.mileage < $1.mileage })?.mileage
    }

    private let db = Firestore.firestore()
    
    var didRefreshOnThisLaunch = false

    init() {
        fetchUserName()
        Task { [weak self] in
            await self?.refreshOncePerLaunch()
        }
    }
    
    func refreshOncePerLaunch() async {
        guard !didRefreshOnThisLaunch else { return }

        await loadVehicleData()

        if let vehicle = primaryVehicle, !vehicle.id.isEmpty {
            await updateDvlaDates(registration: vehicle.registration, vehicleId: vehicle.id)

            async let mods: Void = loadModifications(vehicle.id)
            async let fuels: Void = loadFuelLogs(vehicle.id)
            _ = await (mods, fuels)

            await loadModifications(vehicle.id)
            await loadFuelLogs(vehicle.id)
        }
        didRefreshOnThisLaunch = true
    }
    

    func fetchUserName() {
        guard let user = Auth.auth().currentUser else {
            name = "User"
            profilePhotoURL = nil
            isProfileLoading = false
            return
        }

        isProfileLoading = true

        Task {
            do {
                try await user.reload()
            } catch {
                print("Failed to reload user: \(error.localizedDescription)")
            }

            let refreshedUser = Auth.auth().currentUser

            // FIRST: try Firebase Auth photoURL (Google accounts)
            if let authPhotoURL = refreshedUser?.photoURL {
                self.profilePhotoURL = authPhotoURL
            }

            // Display name
            if let displayName = refreshedUser?.displayName, !displayName.isEmpty {
                self.name = displayName
            }

            do {
                let document = try await db.collection("users").document(user.uid).getDocument()

                if document.exists {
                    let data = document.data()

                    // SECOND: Firestore photoURL (email/password users)
                    if self.profilePhotoURL == nil,
                       let photoURLString = data?["photoURL"] as? String,
                       let url = URL(string: photoURLString) {
                        self.profilePhotoURL = url
                    }

                    // Firestore name fallback
                    if self.name.isEmpty,
                       let fetchedName = data?["name"] as? String,
                       !fetchedName.isEmpty {
                        self.name = fetchedName
                    }
                }

                if self.name.isEmpty {
                    self.name = "User"
                }

            } catch {
                print("Firestore fetch error: \(error.localizedDescription)")
                self.name = "User"
            }

            self.isProfileLoading = false
        }
    }
    
    // Format Date as Day(st, nd, rd, th) Month Year
    func dateFormatter(_ date: Date?) -> String {
        guard let date = date else { return "Could not get date" }

        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)

        // Determine the suffix (st, nd, rd, th)
        let suffix: String
        switch day {
        case 1, 21, 31: suffix = "st"
        case 2, 22: suffix = "nd"
        case 3, 23: suffix = "rd"
        default: suffix = "th"
        }

        // Format month and year
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        let monthYear = formatter.string(from: date)

        return "\(day)\(suffix) \(monthYear)"
    }
    
    // Returns the signed number of days between today and the provided date.
    func daysBetweenToday(date: Date?) -> Int {
        guard let date = date else { return 0 }
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let targetStart = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.day], from: todayStart, to: targetStart)
        return components.day ?? 0
    }
    
    // Format Date as Day(st, nd, rd, th) Month Year
    func modDateFormatter(_ date: Date?) -> String {
        guard let date = date else { return "Could not get date" }

        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)

        // Format month and year
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"

        let monthYear = formatter.string(from: date)

        return "\(day) \(monthYear)"
    }
    
    // Fetches and update the latest MOT and Tax dates from DVLA
    func updateDvlaDates(registration: String, vehicleId: String) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "No logged in user."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let dvla = try await DVLAService().fetchVehicle(for: registration)

            // DVLA dates are typically "yyyy-MM-dd"
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_GB")
            df.timeZone = TimeZone(secondsFromGMT: 0)
            df.dateFormat = "yyyy-MM-dd"

            var update: [String: Any] = [:]

            // MOT
            if let motStatus = dvla.motStatus {
                update["motStatus"] = motStatus
            }
            if let motExpiryStr = dvla.motExpiryDate,
               let motDate = df.date(from: motExpiryStr) {
                update["motExpiryDate"] = Timestamp(date: motDate)
            }

            // TAX
            if let taxStatus = dvla.taxStatus {
                update["taxStatus"] = taxStatus
            }
            if let taxDueStr = dvla.taxDueDate,
               let taxDate = df.date(from: taxDueStr) {
                update["taxExpiryDate"] = Timestamp(date: taxDate) // your Firestore field name
            }

            guard !update.isEmpty else {
                errorMessage = "DVLA returned no MOT/Tax fields to update."
                return
            }

            try await db.collection("users")
                .document(uid)
                .collection("vehicles")
                .document(vehicleId)
                .updateData(update)

            // Refresh local model
            await loadVehicleData()
            if let id = primaryVehicle?.id {
                await loadModifications(id)
            }

        } catch let urlError as URLError {
            errorMessage = "Failed to refresh from DVLA: \(urlError.localizedDescription)"
        } catch {
            errorMessage = "Failed to refresh from DVLA: \(error.localizedDescription)"
        }
    }
    
    func loadVehicleData() async{
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "No logged in user."
            return
        }
        
        isLoading = true
        // Artificial delay to mimic a brief loading pause
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        errorMessage = nil
        
        do {
            let query = db
                .collection("users")
                .document(uid)
                .collection("vehicles")
                .whereField("isPrimary", isEqualTo: true)
                .limit(to: 1)
            
            let snapshot = try await query.getDocuments()
            
            if snapshot.documents.isEmpty {
                primaryVehicle = nil
                return
            }
            
            let decoded = try snapshot.documents.map { doc in
                try doc.data(as: VehicleModel.self)
            }
            
            let vehicle = decoded.first
            primaryVehicle = vehicle
        } catch {
            errorMessage = "Failed to load vehicle: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // Load modification list
    func loadModifications(_ vehicleId: String) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "No logged in user."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let snapshot = try await db
                .collection("users")
                .document(uid)
                .collection("vehicles")
                .document(vehicleId)
                .collection("modifications")
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let decoded = try snapshot.documents.map { doc in
                try doc.data(as: ModificationModel.self)
            }
            
            modifications = decoded
        } catch {
            errorMessage = "Failed to load modifications: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // Load fuel logs
    func loadFuelLogs(_ vehicleId: String) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "No logged in user."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let snapshot = try await db
                .collection("users")
                .document(uid)
                .collection("vehicles")
                .document(vehicleId)
                .collection("fuelLogs")
                .order(by: "createdAt", descending: false)
                .getDocuments()
            
            let decoded = try snapshot.documents.map { doc in
                try doc.data(as: FuelLogModel.self)
            }
            
            fuelLogs = decoded
        } catch {
            errorMessage = "Failed to load fuel logs: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

