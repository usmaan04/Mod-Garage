//
//  VehicleReportView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 13/04/2026.
//

import SwiftUI

struct VehicleReportView: View {
    let vehicle: VehicleModel
    let modifications: [ModificationModel]
    let fuelLogs: [FuelLogModel]
    let latestMileage: Int?

    private var recentModifications: [ModificationModel] {
        modifications
            .sorted(by: { $0.date > $1.date })
            .prefix(3)
            .map { $0 }
    }

    private var recentFuelLogs: [FuelLogModel] {
        fuelLogs
            .sorted(by: { $0.date > $1.date })
            .prefix(5)
            .map { $0 }
    }

    private var totalFuelSpend: Double {
        fuelLogs.reduce(0) { $0 + $1.cost }
    }

    private var totalFuelLitres: Double {
        fuelLogs.reduce(0) { $0 + $1.litres }
    }

    private var averagePricePerLitre: Double {
        guard !fuelLogs.isEmpty else { return 0 }
        return fuelLogs.reduce(0) { $0 + $1.pricePerLitre } / Double(fuelLogs.count)
    }

    var body: some View {
        VStack(spacing: 28) {
            headerSection

            HStack(spacing: 8){
                VStack(alignment: .leading, spacing: 8){
                    VStack{
                        Text("Vehicle Information")
                            .font(.system(size: 10).weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.redTheme)
                            )
                        
                        VStack(spacing: 0) {
                            reportInfoRow("Make", vehicle.make, boldValue: true)
                            reportInfoRow("Model", vehicle.model, boldValue: true)
                            reportInfoRow("Year", "\(vehicle.year)")
                            reportInfoRow("Registration", vehicle.registration, boldValue: true)
                            reportInfoRow("Fuel Type", vehicle.fuelType)
                            reportInfoRow("Current Mileage", latestMileage.map { "\($0) mi" } ?? "N/A")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .stroke(Color.rectBorder, lineWidth: 1)
                    )
                    
                    modificationsCard
                    
                }
                .frame(maxWidth: 220, maxHeight: .infinity, alignment: .top)
                
                VStack(alignment: .leading, spacing: 8){
                    topStatCards
                    fuelLogsCard
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.rectFill)
            )
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.white)
        .foregroundStyle(Color.black)
    }

    private var headerSection: some View {
        VStack(spacing: 14) {
            Text("Mod Garage")
                .font(.system(size: 34, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(Color.redTheme)

            HStack(spacing: 14) {
                Rectangle()
                    .fill(Color.redTheme.opacity(0.8))
                    .frame(height: 1)

                Text("Vehicle Report")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.black.opacity(0.85))
                    .fixedSize()

                Rectangle()
                    .fill(Color.redTheme.opacity(0.8))
                    .frame(height: 1)
            }

            VStack(spacing: 6) {
                Text("\(vehicle.make) \(vehicle.model)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.black.opacity(0.9))

                Text("Generated on \(Date().formatted(date: .long, time: .omitted))")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.black.opacity(0.55))
            }
        }
    }
    
    private func reportInfoRow(_ label: String, _ value: String, boldValue: Bool = false) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Text("\(label):")
                    .font(.system(size: 11, weight: .semibold))

                Spacer()

                Text(value)
                    .font(.system(size: 11, weight: boldValue ? .bold : .regular))
                    .foregroundStyle(Color.black.opacity(0.9))
            }
            .padding(.vertical, 11)

            Divider()
        }
    }
    
    private var modificationsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Recent Modifications")
                .font(.system(size: 10).weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.redTheme)
                )

            VStack(alignment: .leading, spacing: 0) {
                if recentModifications.isEmpty {
                    emptyState("No modifications recorded.")
                        .padding(18)
                } else {
                    ForEach(Array(recentModifications.enumerated()), id: \.element.id) { index, mod in
                        HStack(alignment: .top, spacing: 10) {
                            Circle()
                                .fill(Color.redTheme)
                                .frame(width: 7, height: 7)
                                .padding(.top, 7)

                            VStack(alignment: .leading, spacing: 5) {
                                HStack(spacing: 4) {
                                    Text(mod.name)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(Color.black.opacity(0.9))

                                    Text("•")
                                        .foregroundStyle(Color.black.opacity(0.45))

                                    Text(mod.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(Color.black.opacity(0.65))
                                }

                                Text(mod.type)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Color.black.opacity(0.55))
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)

                        if index != recentModifications.count - 1 {
                            Divider()
                                .padding(.horizontal, 18)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: . infinity, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .stroke(Color.rectBorder, lineWidth: 1)
        )
    }
    
    private var topStatCards: some View {
        HStack(spacing: 0) {
            iconStatCard(
                icon: "wrench.and.screwdriver.fill",
                title: "Total Modifications",
                value: "\(modifications.count)"
            )

            Divider()

            iconStatCard(
                icon: "fuelpump.fill",
                title: "Total Fuel Logs",
                value: "\(fuelLogs.count)"
            )
        }
        .frame(maxWidth: .infinity, maxHeight: 100, alignment: .center)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.rectBorder, lineWidth: 1)
        )
    }
    
    private func iconStatCard(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .center, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(Color.redTheme)
                    .font(.system(size: 13, weight: .bold))

                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.black.opacity(0.8))
            }

            Text(value)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Color.black.opacity(0.9))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
    }
    
    private var fuelLogsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Recent Fuel Logs")
                .font(.system(size: 10).weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.redTheme)
                )

            VStack(alignment: .leading, spacing: 0) {
                if recentFuelLogs.isEmpty {
                    emptyState("No fuel logs recorded.")
                        .padding(18)
                } else {
                    ForEach(Array(recentFuelLogs.enumerated()), id: \.element.id) { index, log in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(log.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.system(size: 13, weight: .bold))

                                Text(" - \(log.litres, specifier: "%.1f")L @ \(currencyString(log.pricePerLitre))/L")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundStyle(Color.black.opacity(0.9))

                            Text("Total: \(currencyString(log.cost)) • Mileage: \(log.mileage) mi")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.black.opacity(0.65))
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)

                        if index != recentFuelLogs.count - 1 {
                            Divider()
                                .padding(.horizontal, 18)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: . infinity, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .stroke(Color.rectBorder, lineWidth: 1)
        )
    }
    
    private func emptyState(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(Color.black.opacity(0.5))
    }

    private func currencyString(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "GBP"
        return formatter.string(from: NSNumber(value: value)) ?? "£0.00"
    }
}

#Preview("Sample Report") {
    let vehicle = VehicleModel(
        id: UUID().uuidString,
        userId: "preview-user",
        registration: "AB12 CDE",
        make: "Audi",
        model: "RS3",
        year: 2024,
        colour: "Nardo Grey",
        fuelType: "Petrol",
        motStatus: "Valid",
        isPrimary: true,
        createdAt: Date()
    )

    let modifications: [ModificationModel] = [
        ModificationModel(
            id: UUID().uuidString,
            type: "Performance",
            name: "Stage 1 Tune",
            cost: 100,
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            createdAt: Date()
        ),
        ModificationModel(
            id: UUID().uuidString,
            type: "Exhaust",
            name: "Milltek Cat-back Exhaust",
            cost: 100,
            date: Calendar.current.date(byAdding: .day, value: -12, to: Date()) ?? Date(),
            createdAt: Date()
        ),
        ModificationModel(
            id: UUID().uuidString,
            type: "Suspension",
            name: "H&R Lowering Springs",
            cost: 100,
            date: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date(),
            createdAt: Date()
        ),
        ModificationModel(
            id: UUID().uuidString,
            type: "Cooling",
            name: "Forge Intercooler",
            cost: 100,
            date: Calendar.current.date(byAdding: .day, value: -45, to: Date()) ?? Date(),
            createdAt: Date()
        )
    ]

    let fuelLogs: [FuelLogModel] = [
        FuelLogModel(
            id: UUID().uuidString,
            location: "Asda",
            litres: 42.0,
            pricePerLitre: 1.56,
            cost: 65.52,
            mileage: 12410,
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            mpg: 33.54,
            createdAt: Date()
        ),
        FuelLogModel(
            id: UUID().uuidString,
            location: "Tesco",
            litres: 38.7,
            pricePerLitre: 1.52,
            cost: 58.82,
            mileage: 11980,
            date: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(),
            mpg: 34.12,
            createdAt: Date()
        ),
        FuelLogModel(
            id: UUID().uuidString,
            location: "Shell",
            litres: 40.1,
            pricePerLitre: 1.54,
            cost: 61.75,
            mileage: 11620,
            date: Calendar.current.date(byAdding: .day, value: -18, to: Date()) ?? Date(),
            mpg: 31.32,
            createdAt: Date()
        )
    ]

    VehicleReportView(
        vehicle: vehicle,
        modifications: modifications,
        fuelLogs: fuelLogs,
        latestMileage: 12410
    )
    .background(Color(uiColor: .systemGroupedBackground))
}
