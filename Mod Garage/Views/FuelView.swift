//
//  FuelView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 11/11/2025.
//

import Foundation
import SwiftUI

struct FuelView: View {
    @StateObject private var viewModel = FuelViewModel()
    @EnvironmentObject var homeViewModel: HomeViewModel

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 30)
                } else if let _ = viewModel.primaryVehicle {
                    ScrollView(.vertical) {
                        VStack(spacing: 20) {
                            // Timeframe Filters
                            timeframePills
                            // Summary Cards
                            HStack(spacing: 12) {
                                summaryCard(
                                    title: "Total Spending",
                                    value: currencyString(viewModel.totalSpending)
                                )

                                summaryCard(
                                    title: "Avg MPG",
                                    value: mpgString(viewModel.averageMPG)
                                )
                            }

                            // MPG Trends (placeholder container)
                            VStack(alignment: .leading, spacing: 10) {
                                Text("MPG Trends")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.gray)
                                
                                // Replace this with your line chart later
                                chartPlaceholder(text: "Line chart goes here (MPG per month)")
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.rectBorder, lineWidth: 4)
                                    .fill(Color.boxbackground)
                            )

                            // Spending (placeholder container)
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Spending")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.gray)

                                // Replace this with your bar chart later
                                chartPlaceholder(text: "Bar chart goes here (spending per month)")
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.rectBorder, lineWidth: 4)
                                    .fill(Color.boxbackground)
                            )

                            // Empty state for logs (optional)
                            if viewModel.filteredLogs.isEmpty {
                                Text("No fuel logs found for this timeframe.")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.navText)
                                    .padding(.top, 4)
                            }

                        }
                        .padding(17)
                    }
                } else {
                    Text("Hey there, please add a vehicle to see your fuel details")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.navText)
                        .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.background)
            .navigationTitle("Fuel & Efficiency")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.loadFuelScreenData()
            }
        }
    }

    // MARK: - Timeframe pills UI

    private var timeframePills: some View {
        HStack(spacing: 10) {
            ForEach(FuelTimeframe.allCases) { timeframe in
                Button {
                    viewModel.selectedTimeframe = timeframe
                } label: {
                    Text(timeframe.label)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(
                            viewModel.selectedTimeframe == timeframe ? Color.boxbackground : Color.navText
                        )
                        .padding(.vertical, 12)
                        .frame(maxWidth:.infinity, maxHeight: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(viewModel.selectedTimeframe == timeframe ? Color.redTheme : Color.boxbackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(viewModel.selectedTimeframe == timeframe ? Color.redTheme : Color.boxbackground)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.boxbackground)
        )
    }

    // Reusable UI bits

    private func summaryCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 12).weight(.semibold))
                .tracking(-0.6)
                .textCase(.uppercase)
                .foregroundStyle(Color.gray)

            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.lightBlack)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.rectBorder, lineWidth: 4)
                .fill(Color.boxbackground)
        )
    }

    private func chartPlaceholder(text: String) -> some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundStyle(Color.navText.opacity(0.8))
            .frame(maxWidth: .infinity, minHeight: 140, alignment: .center)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.boxbackground.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.rectBorder.opacity(0.6), lineWidth: 1)
                    )
            )
    }

    // Formatting helpers

    private func currencyString(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "GBP" // change if needed
        return formatter.string(from: NSNumber(value: value)) ?? "£0.00"
    }

    private func mpgString(_ value: Double?) -> String {
        guard let value else { return "—" }
        return String(format: "%.1f", value)
    }
}

#Preview {
    FuelView()
}
