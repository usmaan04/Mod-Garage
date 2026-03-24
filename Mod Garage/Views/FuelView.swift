//
//  FuelView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 11/11/2025.
//

import Foundation
import SwiftUI
import Charts

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

struct FuelView: View {
    @StateObject private var viewModel = FuelViewModel()
    @EnvironmentObject var homeViewModel: HomeViewModel
    @Namespace private var timeframeNamespace

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 30)
            } else if let _ = viewModel.primaryVehicle {
                VStack{
                    HStack {
                        Text("Fuel & Efficiency")
                            .foregroundStyle(.lightBlack)
                            .font(.system(size: 18).weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button {
                            viewModel.isShowingAddFuelLog = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.redTheme)
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .zIndex(30)
                .padding(.horizontal, 17)
                .padding(.bottom, 17)
                .frame(maxWidth: .infinity, maxHeight: 64)
                .background(Color.backgroundW)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                GeometryReader{ proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Timeframe Filters
                            timeframePills
                            // Summary Cards
                            HStack(spacing: 12) {
                                summaryCard(
                                    title: "Total Spending",
                                    value: currencyString(from: viewModel.totalSpending)
                                )

                                summaryCard(
                                    title: "Avg MPG",
                                    value: mpgString(viewModel.averageMPG)
                                )
                            }

                            // MPG Trends (placeholder container)
                            VStack(alignment: .leading, spacing: 16) {
                                Text("MPG TRENDS")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.lightBlack)
                                
                                if viewModel.mpgChartPoints.isEmpty {
                                        emptyChartState("No MPG data for this timeframe.")
                                } else {
                                    Chart(viewModel.mpgChartPoints) { point in
                                        LineMark(
                                            x: .value("Date", point.x),
                                            y: .value("Avg MPG", point.avgMPG)
                                        )
                                        .foregroundStyle(Color.redTheme)
                                        PointMark(
                                            x: .value("Date", point.x),
                                            y: .value("Avg MPG", point.avgMPG)
                                        )
                                        .foregroundStyle(Color.redTheme)
                                    }
                                    .frame(height: 180)
                                    .chartXScale(domain: viewModel.chartDomain ?? Date.distantPast...Date())
                                    .chartXScale(range: .plotDimension(padding: 10))
                                    .chartXAxis {
                                        switch viewModel.selectedTimeframe {
                                        case .oneMonth:
                                            AxisMarks(values: viewModel.dayTicksForAnchorMonth(step: 5)) {
                                                value in
                                                AxisValueLabel(centered: false) {
                                                    if let date = value.as(Date.self) {
                                                        Text(date, format: .dateTime.day())
                                                    }
                                                }
                                            }


                                        case .sixMonths, .oneYear:
                                            AxisMarks(values: .stride(by: .month)) { value in
                                                AxisValueLabel(centered: true) {
                                                    if let date = value.as(Date.self) {
                                                        Text(date, format: .dateTime.month(.abbreviated))
                                                            .frame(maxWidth: .infinity, alignment: .center)
                                                    }
                                                }
                                            }

                                        case .all:
                                            AxisMarks(values: .stride(by: .year)) { value in
                                                AxisValueLabel(centered: true)
                                            }
                                        }
                                    }
                                    .chartYAxis {
                                        AxisMarks(position: .leading)
                                    }
                                }
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.rectBorder, lineWidth: 4)
                                    .fill(Color.boxbackground)
                            )

                            VStack(alignment: .leading, spacing: 16) {
                                Text("Spending")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.lightBlack)

                                if viewModel.spendChartPoints.isEmpty {
                                    emptyChartState("No spending data for this timeframe.")
                                } else {
                                    let barWidth: MarkDimension = {
                                        switch viewModel.selectedTimeframe {
                                        case .oneMonth: return .fixed(6)
                                        case .sixMonths: return .fixed(35)
                                        case .oneYear: return .fixed(25)
                                        case .all: return .fixed(16)
                                        }
                                    }()

                                    Chart(viewModel.spendChartPoints) { point in
                                        BarMark(
                                            x: .value("Date", point.x),
                                            y: .value("Total Spend", point.totalSpend),
                                            width: barWidth
                                        )
                                        .foregroundStyle(Color.redTheme)
                                    }
                                    .frame(height: 180)
                                    .chartXScale(domain: viewModel.chartDomain ?? Date.distantPast...Date())
                                    .chartXScale(range: .plotDimension(padding: 10))
                                    .chartXAxis {
                                        switch viewModel.selectedTimeframe {
                                        case .oneMonth:
                                            AxisMarks(values: viewModel.dayTicksForAnchorMonth(step: 5)) { value in
                                                AxisValueLabel(centered: false) {
                                                    if let date = value.as(Date.self) {
                                                        Text(date, format: .dateTime.day())
                                                            
                                                    }
                                                }
                                            }

                                        case .sixMonths, .oneYear:
                                            AxisMarks(values: .stride(by: .month)) { value in
                                                AxisValueLabel(centered: true) {
                                                    if let date = value.as(Date.self) {
                                                        Text(date, format: .dateTime.month(.abbreviated))
                                                    }
                                                }
                                            }

                                        case .all:
                                            AxisMarks(values: .stride(by: .year)) { value in
                                                AxisValueLabel(centered: true) {
                                                    if let date = value.as(Date.self) {
                                                        Text(date, format: .dateTime.year())
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .chartYAxis {
                                        AxisMarks(position: .leading) { value in
                                            AxisGridLine()
                                            AxisTick()
                                            AxisValueLabel {
                                                if let v = value.as(Double.self) {
                                                    Text(spendingCurrencyString(from: v))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.rectBorder, lineWidth: 4)
                                    .fill(Color.boxbackground)
                            )
                            
                            HStack{
                                Text("Recent Logs")
                                    .foregroundColor(.lightBlack)
                                    .font(.system(size: 16).weight(.semibold))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Button{
                                    viewModel.isShowingAllLogs = true
                                }label:{
                                    Text("See All")
                                        .padding(.trailing, 10)
                                        .foregroundColor(.redTheme)
                                        .font(.system(size: 14).weight(.semibold))
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                            }
                            
                            VStack{
                                ForEach(viewModel.fuelLogs
                                    .sorted { $0.date > $1.date }
                                    .prefix(3)
                                ) { fuelLog in
                                    FuelLogCard(
                                        fuelLog: fuelLog,
                                    )
                                    .environmentObject(homeViewModel)
                                    .environmentObject(viewModel)
                                    
                                }
                                .padding(.bottom, 4)
                            }

                            // Empty state for logs (optional)
                            if viewModel.filteredLogs.isEmpty {
                                Text("No fuel logs found for this timeframe.")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.navText)
                                    .padding(.top, 4)
                            }

                        }
                        .padding(.horizontal, 17)
                        .padding(.vertical, 16)
                    }
                    .frame(maxHeight: proxy.size.height - 84)
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
        .sheet(isPresented: $viewModel.isShowingAddFuelLog) {
            addFuelLogSheet
        }
        .sheet(isPresented:$viewModel.isShowingAllLogs){
            ScrollView{
                ForEach(viewModel.fuelLogs
                    .sorted { $0.date > $1.date }
                ) { fuelLog in
                    FuelLogCard(
                        fuelLog: fuelLog,
                    )
                    .environmentObject(homeViewModel)
                    .environmentObject(viewModel)
                    
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 36)
            }
            .frame(maxWidth: .infinity)
            .background(Color.background)
            .presentationDragIndicator(.visible)
        }
        .task {
            await viewModel.loadFuelScreenData()
        }
    }
    
    private var addFuelLogSheet: some View {
        Group {
            if let vehicleId = viewModel.primaryVehicle?.id {
                NavigationStack {
                    AddFuelLogView(
                        vehicleId: vehicleId,
                        method: "fuel",
                        previousMileage: viewModel.latestFuelLogMileage
                    )
                    .environmentObject(viewModel)
                }
                .presentationDragIndicator(.visible)
            } else {
                Text("No vehicle selected.")
            }
        }
    }

    // Timeframe pills UI

    private var timeframePills: some View {
        HStack(spacing: 10) {
            ForEach(FuelTimeframe.allCases) { timeframe in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0.2)) {
                        viewModel.selectedTimeframe = timeframe
                    }
                } label: {
                    ZStack {
                        if viewModel.selectedTimeframe == timeframe {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.backgroundW)
                                .matchedGeometryEffect(id: "timeframeHighlight", in: timeframeNamespace)
                        }
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.clear)
                        Text(timeframe.label)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(
                                viewModel.selectedTimeframe == timeframe ? Color.redTheme : Color.navText
                            )
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, maxHeight: 44)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.rectBorder)
        )
    }

    // Reusable UI
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
    
    private func emptyChartState(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundStyle(Color.navText.opacity(0.8))
            .frame(maxWidth: .infinity, minHeight: 180, alignment: .center)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.boxbackground.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.rectBorder.opacity(0.6), lineWidth: 1)
                    )
            )
    }

    private func mpgString(_ value: Double?) -> String {
        guard let value else { return "—" }
        return String(format: "%.1f", value)
    }
}

struct FuelLogCard: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var viewModel: FuelViewModel

    let fuelLog: FuelLogModel

    var body: some View {
        HStack(spacing: 20){
            ZStack{
                Circle()
                    .fill(Color.black)
                    .frame(width: 50, height: 50)
                
                VStack(spacing: 1) {
                    Text(viewModel.monthString(from: fuelLog.date))
                        .font(.system(size: 8, weight: .semibold))
                        .tracking(-0.2)
                        .foregroundStyle(Color.bodyText)
                    Text(viewModel.dayString(from: fuelLog.date))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.boxbackground)
                }
            }
            VStack(alignment: .leading, spacing: 4){
                HStack() {
                    Text(fuelLog.location)
                        .font(.system(size: 16).weight(.bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(currencyString(from: fuelLog.cost))
                        .font(.system(size: 18).weight(.bold))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .foregroundStyle(Color.lightBlack)
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 4) {
                    Text(String(format: "%.2f L", fuelLog.litres))
                    Text("●")
                        .font(.system(size: 4))
                    Text(String(format: "£%.2f/L", fuelLog.pricePerLitre))
                    
                    if fuelLog.mpg > 30 {
                        Text(String(format: "%.2f MPG", fuelLog.mpg))
                            .foregroundStyle(Color.green)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    } else {
                        Text(String(format: "%.2f MPG", fuelLog.mpg))
                            .foregroundStyle(Color.red)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .font(.system(size: 12).weight(.semibold))
                .foregroundStyle(Color.navText)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.boxbackground)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
}

#Preview {
    FuelView()
        .environmentObject(HomeViewModel())
}

