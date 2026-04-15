//
//  VehicleDetailViewModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 10/01/2026.
//

import Foundation
import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth

// Represents the different toggles/ pills in the detail view
// Check whether to look at vehicles mods or fuel logs
enum ListOption: String, CaseIterable, Identifiable {
    case mods
    case logs

    var id: String { rawValue }

    // Display label for the UI pills
    var label: String {
        switch self {
        case .mods: return "Mods"
        case .logs: return "Fuel Logs"
        }
    }

}

// Handles logic for displaying singular vehicle information in the vehicle detail view
@MainActor
final class VehicleDetailViewModel: ObservableObject {

    // UI state for showing sheets and managing tab selection
    @Published var isShowingAddModification = false
    @Published var isShowingAddFuelLog = false
    @Published var listOption: ListOption = .mods
    @Published var modifications: [ModificationModel] = []
    @Published var fuelLogs: [FuelLogModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    // Properties for the PDF Export feature
    @Published var reportURL: URL?
    @Published var isGeneratingReport = false
    
    // Gets the highest fuel log odometer/mileage value
    var latestFuelLogMileage: Int? {
        fuelLogs.max(by: { $0.mileage < $1.mileage })?.mileage
    }

    private let db = Firestore.firestore()

    // Adds a new mod into the modifications subcollection
    func addModification(_ modification: ModificationModel, vehicleId: String) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "No logged in user."
            return
        }
        
        let modsCollection = db
            .collection("users")
            .document(uid)
            .collection("vehicles")
            .document(vehicleId)
            .collection("modifications")
        
        do {
            try modsCollection.addDocument(from: modification)
            await loadModifications(vehicleId)
            isShowingAddModification = false
        
        } catch {
            errorMessage = "Failed to save modification: \(error.localizedDescription)"
        }
    }
    
    // Adds a new fuel log into the fuelLogs subcollection
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
            await loadFuelLogs(vehicleId)
            isShowingAddFuelLog = false
        } catch {
            errorMessage = "Failed to save fuel log: \(error.localizedDescription)"
        }
    }
    
    // Gets the modifications stored in Firestore
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
                .order(by: "createdAt", descending: false)
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
    
    // Gets the fuel logs stored in Firestore
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
    
    // Gets the current vehicle and calls PDFGenerator service file
    func generateVehicleReportPDF(vehicle: VehicleModel) async {
        isGeneratingReport = true
        reportURL = nil

        defer { isGeneratingReport = false }

        do {
            let url = try PDFGenerator.createVehicleReportPDF(
                vehicle: vehicle,
                modifications: modifications,
                fuelLogs: fuelLogs,
                latestMileage: latestFuelLogMileage
            )

            reportURL = url
        } catch {
            errorMessage = "Failed to generate report: \(error.localizedDescription)"
        }
    }
}
