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
    // If you have a specific currency, set it here; otherwise it uses locale
    return formatter.string(from: NSNumber(value: value)) ?? "—"
}

struct FuelView: View {
    @StateObject private var viewModel = FuelViewModel()
    @EnvironmentObject var homeViewModel: HomeViewModel
    @Namespace private var timeframeNamespace

    var body: some View {
        VStack(spacing: 0) {
            VStack{
                HStack {
                    Text("Fuel & Efficiency")
                        .font(.system(size: 22).weight(.semibold))
                        .fontWidth(.condensed)
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
                // Timeframe Filters
                timeframePills
            }
            .zIndex(30)
            .padding(.horizontal, 17)
            .frame(maxWidth: .infinity, maxHeight: 84)
            .background(Color.container)
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 30)
            } else if let _ = viewModel.primaryVehicle {
                GeometryReader{ proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
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
                            
                            Text("Efficiency Trends")
                                .font(.system(size: 18).weight(.semibold))
                                .fontWidth(.condensed)
                                .frame(maxWidth: .infinity, alignment: .leading)
                             
                            // MPG Trends (placeholder container)
                            VStack(alignment: .leading, spacing: 24) {
                                VStack(alignment: .leading, spacing: 4){
                                    switch viewModel.selectedTimeframe {
                                    case .oneMonth:
                                        Text("Daily MPG")
                                            .font(.system(size: 18).weight(.regular))
                                            .fontWidth(.condensed)
                                            .foregroundStyle(Color.containerText)
                                    case .sixMonths, .oneYear:
                                        Text("Monthly MPG")
                                            .font(.system(size: 18).weight(.regular))
                                            .fontWidth(.condensed)
                                            .foregroundStyle(Color.containerText)
                                    case .all:
                                        Text("Yearly MPG")
                                            .font(.system(size: 18).weight(.regular))
                                            .fontWidth(.condensed)
                                            .foregroundStyle(Color.containerText)
                                    }
                                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                                        Text(mpgString(viewModel.mpgHeaderText))
                                            .font(.system(size: 24).weight(.bold))
                                        Text("Avg")
                                            .font(.system(size: 16).weight(.regular))
                                            .fontWidth(.condensed)
                                            .foregroundStyle(Color.containerText.opacity(0.8))
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                                if viewModel.mpgChartPoints.isEmpty {
                                        emptyChartState("No MPG data for this timeframe.")
                                } else {
                                    Chart(viewModel.mpgChartPoints) { point in
                                        RuleMark(y: .value("Baseline", 0))
                                            .foregroundStyle(Color.containerText.opacity(0.1))
                                            .lineStyle(StrokeStyle(lineWidth: 1))
                                        LineMark(
                                            x: .value("Date", point.x),
                                            y: .value("Avg MPG", point.avgMPG)
                                        )
                                        .foregroundStyle(
                                            viewModel.selectedMPGPoint == nil
                                            ? Color.redTheme
                                            : Color.containerText
                                        )
                                        PointMark(
                                            x: .value("Date", point.x),
                                            y: .value("Avg MPG", point.avgMPG)
                                        )
                                        .symbolSize(100)
                                        .foregroundStyle(
                                            viewModel.selectedMPGPoint == nil || viewModel.selectedMPGPoint?.id == point.id
                                            ? Color.redTheme
                                            : Color.containerText
                                        )
                                    }
                                    .frame(height: 180)
                                    .chartXScale(domain: viewModel.chartDomain ?? Date.distantPast...Date())
                                    .chartXScale(range: .plotDimension(padding: 10))
                                    .chartOverlay { proxy in
                                        GeometryReader { geometry in
                                            Rectangle().fill(.clear).contentShape(Rectangle())
                                                .gesture(
                                                    SpatialTapGesture()
                                                        .onEnded { value in
                                                            let location = value.location
                                                            // Find the date on the X axis
                                                            if let date: Date = proxy.value(atX: location.x) {
                                                                // Find the point closest to this date
                                                                let closest = viewModel.mpgChartPoints.min(by: {
                                                                    abs($0.x.timeIntervalSince(date)) < abs($1.x.timeIntervalSince(date))
                                                                })
                                                                
                                                                // If clicking the same bar, deselect it
                                                                if viewModel.selectedMPGPoint?.id == closest?.id {
                                                                    viewModel.selectedMPGPoint = nil
                                                                } else {
                                                                    viewModel.selectedMPGPoint = closest
                                                                }
                                                            }
                                                        }
                                                )
                                        }
                                    }
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
                                        AxisMarks(position: .leading) {
                                            AxisGridLine()
                                        }
                                    }
                                }
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.containerBorder, lineWidth: 4)
                                    .fill(Color.container)
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 0)
                            )

                            Text("Spending")
                                .font(.system(size: 18).weight(.semibold))
                                .fontWidth(.condensed)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(alignment: .leading, spacing: 24) {
                                VStack(alignment: .leading, spacing: 4){
                                    switch viewModel.selectedTimeframe {
                                    case .oneMonth:
                                        Text("Daily Spending")
                                            .font(.system(size: 18).weight(.regular))
                                            .fontWidth(.condensed)
                                            .foregroundStyle(Color.containerText)
                                    case .sixMonths, .oneYear:
                                        Text("Monthly Spending")
                                            .font(.system(size: 18).weight(.regular))
                                            .fontWidth(.condensed)
                                            .foregroundStyle(Color.containerText)
                                    case .all:
                                        Text("Yearly Spending")
                                            .font(.system(size: 18).weight(.regular))
                                            .fontWidth(.condensed)
                                            .foregroundStyle(Color.containerText)
                                    }
                                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                                        Text(viewModel.spendingHeaderText)
                                            .font(.system(size: 24).weight(.bold))
                                        Text("Total")
                                            .font(.system(size: 16).weight(.regular))
                                            .fontWidth(.condensed)
                                            .foregroundStyle(Color.containerText.opacity(0.8))
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                                if viewModel.spendChartPoints.isEmpty {
                                    emptyChartState("No spending data for this timeframe.")
                                } else {
                                    let barWidth: MarkDimension = {
                                        switch viewModel.selectedTimeframe {
                                        case .oneMonth: return .fixed(15)
                                        case .sixMonths: return .fixed(50)
                                        case .oneYear: return .fixed(25)
                                        case .all: return .fixed(45)
                                        }
                                    }()

                                    Chart(viewModel.spendChartPoints) { point in
                                        RuleMark(y: .value("Baseline", 0))
                                            .foregroundStyle(Color.containerText.opacity(0.1))
                                            .lineStyle(StrokeStyle(lineWidth: 1))
                                        BarMark(
                                            x: .value("Date", point.x),
                                            y: .value("Total Spend", point.totalSpend),
                                            width: barWidth
                                        )
                                        .cornerRadius(4)
                                        .foregroundStyle(
                                            viewModel.selectedSpendPoint == nil || viewModel.selectedSpendPoint?.id == point.id
                                            ? Color.redTheme
                                            : Color.containerText
                                        )
                                    }
                                    .frame(height: 180)
                                    .chartXScale(domain: viewModel.chartDomain ?? Date.distantPast...Date())
                                    .chartXScale(range: .plotDimension(padding: 10))
                                    .chartOverlay { proxy in
                                        GeometryReader { geometry in
                                            Rectangle().fill(.clear).contentShape(Rectangle())
                                                .gesture(
                                                    SpatialTapGesture()
                                                        .onEnded { value in
                                                            let location = value.location
                                                            // Find the date on the X axis
                                                            if let date: Date = proxy.value(atX: location.x) {
                                                                // Find the point closest to this date
                                                                let closest = viewModel.spendChartPoints.min(by: {
                                                                    abs($0.x.timeIntervalSince(date)) < abs($1.x.timeIntervalSince(date))
                                                                })
                                                                
                                                                // If clicking the same bar, deselect it
                                                                if viewModel.selectedSpendPoint?.id == closest?.id {
                                                                    viewModel.selectedSpendPoint = nil
                                                                } else {
                                                                    viewModel.selectedSpendPoint = closest
                                                                }
                                                            }
                                                        }
                                                )
                                        }
                                    }
                                    .chartXAxis {
                                        switch viewModel.selectedTimeframe {
                                        case .oneMonth:
                                            AxisMarks(values: viewModel.dayTicksForAnchorMonth(step: 5)) { value in
                                                AxisValueLabel(centered: false) {
                                                    if let date = value.as(Date.self) {
                                                        Text(date, format: .dateTime.day())
                                                            .font(.system(size: 12).weight(.medium))
                                                            
                                                    }
                                                }
                                            }

                                        case .sixMonths, .oneYear:
                                            AxisMarks(values: .stride(by: .month)) { value in
                                                AxisValueLabel(centered: true) {
                                                    if let date = value.as(Date.self) {
                                                        Text(date, format: .dateTime.month(.abbreviated))
                                                            .font(.system(size: 12).weight(.medium))
                                                    }
                                                }
                                            }

                                        case .all:
                                            AxisMarks(values: .stride(by: .year)) { value in
                                                AxisValueLabel(centered: true) {
                                                    if let date = value.as(Date.self) {
                                                        Text(date, format: .dateTime.year())
                                                            .font(.system(size: 12).weight(.medium))
                                                    }
                                                }
                                            }
                                        }
                                    }
                                 
                                    .frame(maxWidth: .infinity)
                                    .chartYAxis {
                                        AxisMarks(position: .leading) {
                                            AxisGridLine()
                                        }
                                    }
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.containerBorder, lineWidth: 4)
                                    .fill(Color.container)
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 0)
                            )
                            
                            HStack{
                                Text("Recent Logs")
                                    .font(.system(size: 18).weight(.semibold))
                                    .fontWidth(.condensed)
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
                                    .foregroundStyle(Color.containerText)
                                    .padding(.top, 4)
                            }

                        }
                        .padding(.horizontal, 17)
                        .padding(.vertical, 16)
                    }
                    .frame(maxHeight: proxy.size.height - 84)
                    .gesture(
                        DragGesture(minimumDistance: 20)
                            .onEnded { value in
                                handleTimeframeSwipe(value)
                            }
                    )
                }
                
            } else {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.container)
                            .frame(width: 80, height: 80)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        Image(systemName: "car.fill")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundStyle(Color.redTheme)
                    }

                    Text("No vehicle yet")
                        .font(.system(size: 18, weight: .semibold))

                    Text("Add your first vehicle to start tracking fuel and efficiency stats.")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.containerText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    Button {
                       //
                    } label: {
                        Text("Add Vehicle")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.redTheme)
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 40)
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
                    VStack {
                        Text(timeframe.label)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(
                                viewModel.selectedTimeframe == timeframe ? Color.bw : Color.containerText
                            )
                            .padding(.bottom, 6)
                        
                        Divider()
                            .frame(maxWidth: 40, maxHeight: 3)
                            .background( viewModel.selectedTimeframe == timeframe ? Color.redTheme : Color.clear)
                    }
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
        }
        .offset(y:4.9)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func handleTimeframeSwipe(_ value: DragGesture.Value) {
        let horizontalAmount = value.translation.width
        let verticalAmount = value.translation.height

        guard abs(horizontalAmount) > abs(verticalAmount),
              abs(horizontalAmount) > 40 else { return }

        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            if horizontalAmount > 0 {
                // swipe left -> move backward
                if let next = viewModel.selectedTimeframe.next {
                    viewModel.selectedTimeframe = next
                }
            } else {
                // swipe right -> move forward
                if let previous = viewModel.selectedTimeframe.previous {
                    viewModel.selectedTimeframe = previous
                }
            }
        }
    }

    // Reusable UI
    private func summaryCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 16).weight(.medium))
                .fontWidth(.condensed)
                .foregroundStyle(Color.containerText)

            Text(value)
                .font(.system(size: 20, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.containerBorder, lineWidth: 4)
                .fill(Color.container)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 0)
        )
    }
    
    private func emptyChartState(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundStyle(Color.containerText)
            .frame(maxWidth: .infinity, minHeight: 180, alignment: .center)
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
                        .foregroundStyle(Color.containerText)
                    Text(viewModel.dayString(from: fuelLog.date))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.white)
                }
            }
            VStack(alignment: .leading, spacing: 4){
                HStack() {
                    Text(fuelLog.location)
                        .font(.system(size: 18).weight(.bold))
                        .fontWidth(.condensed)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(currencyString(from: fuelLog.cost))
                        .font(.system(size: 18).weight(.bold))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
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
                .fontWidth(.condensed)
                .foregroundStyle(Color.containerText)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.container)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
}

#Preview {
    FuelView()
        .environmentObject(HomeViewModel())
}

