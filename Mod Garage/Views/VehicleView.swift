//
//  VehicleView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 11/11/2025.
//

import Foundation
import SwiftUI

struct VehicleView: View {
    @EnvironmentObject private var viewModel: VehicleViewModel

    @State private var vehicleToDelete: VehicleModel? = nil
    @State private var showDeleteConfirmation = false

    // Search / Sort / Filters
    @State private var searchText = ""
    @State private var showFilters = false

    enum SortOption: String, CaseIterable, Identifiable {
        case az = "A–Z"
        case za = "Z–A"
        var id: String { rawValue }
    }
    @State private var sortOption: SortOption = .az

    // Filters
    @State private var filterMake: String? = nil
    @State private var filterModel: String? = nil
    @State private var filterColour: String? = nil
    @State private var filterFuel: String? = nil
    
    // Search / Sort / Filters UI

    // Search Field
    private var searchBar: some View {
        TextField(
            "",
            text: $searchText,
            prompt: Text("Search by registration, make or model...")
                .foregroundStyle(Color("bodyText"))
        )
        .font(.system(size: 12))
        .keyboardType(.asciiCapable)
        .autocorrectionDisabled()
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.boxbackground)
                .stroke(Color.rectBorder, lineWidth: 1)
        )
    }

    // Sort Button
    private var sortPicker: some View {
        HStack{
            Menu {
                ForEach(SortOption.allCases) { opt in
                    Button {
                        withAnimation(.smooth) { sortOption = opt}
                    } label: {
                        if sortOption == opt {
                            Label(opt.rawValue, systemImage: "checkmark")
                        } else {
                            Text(opt.rawValue)
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text("Sort:")
                        .font(.system(size: 13).weight(.semibold))
                    
                    Spacer()
                    
                    Text(sortOption.rawValue)
                        .font(.system(size: 13).weight(.semibold))
                        .foregroundStyle(Color.redTheme)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12).weight(.semibold))
                }
            }
        }
        .padding(14)
        .foregroundStyle(Color.white)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.redTheme)
                .stroke(Color(.rectBorder), lineWidth: 1)
        )
    }

    // Main filter button
    private var filtersHeaderRow: some View {
        VStack {
            Button {
                withAnimation(.snappy) { showFilters.toggle() }
            } label: {
                HStack(spacing: 8) {
                    Text("Filter")
                        .font(.system(size: 14).weight(.semibold))

                    if activeFilterCount > 0 {
                        Text("(\(activeFilterCount))")
                            .font(.system(size: 13).weight(.semibold))
                            .foregroundStyle(Color.black)
                    }

                    Spacer()

                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(showFilters ? 180 : 0))
                        .foregroundStyle(Color.white)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .foregroundStyle(Color.white)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.rectBorder)
        )
    }

    // All filters displayed
    private var filtersExpanded: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                filterMenu(title: "Make", selection: $filterMake, options: makes)
                filterMenu(title: "Model", selection: $filterModel, options: models)
            }

            HStack(spacing: 10) {
                filterMenu(title: "Colour", selection: $filterColour, options: colours)
                filterMenu(title: "Fuel Type", selection: $filterFuel, options: fuels)
            }
            Button("Clear") {
                clearFilters()
            }
            .font(.system(size: 13).weight(.semibold))
            .foregroundStyle(Color.redTheme)
            .opacity(activeFilterCount == 0 ? 0.4 : 1)
            .disabled(activeFilterCount == 0)
        }
        .padding(.top, 6)
    }

    // Filter helpers

    private var activeFilterCount: Int {
        [filterMake, filterModel, filterColour, filterFuel].compactMap { $0 }.count
    }

    private func clearFilters() {
        filterMake = nil
        filterModel = nil
        filterColour = nil
        filterFuel = nil
    }

    // Options derived from vehicles
    private var makes: [String] {
        Array(Set(viewModel.vehicles.map { $0.make }))
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    // Models linked to make
    private var models: [String] {
        let base = viewModel.vehicles
        let scoped = (filterMake == nil) ? base : base.filter { $0.make == filterMake }
        return Array(Set(scoped.map { $0.model }))
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    private var colours: [String] {
        Array(Set(viewModel.vehicles.map { $0.colour }))
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    private var fuels: [String] {
        Array(Set(viewModel.vehicles.map { $0.fuelType }))
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    @ViewBuilder
    private func filterMenu(
        title: String,
        selection: Binding<String?>,
        options: [String]
    ) -> some View {
        Menu {
            Button("Any") { selection.wrappedValue = nil }
            ForEach(options, id: \.self) { opt in
                Button(opt) { selection.wrappedValue = opt }
            }
        } label: {
            HStack {
                Text(selection.wrappedValue ?? title)
                    .font(.system(size: 13).weight(.semibold))
                    .foregroundStyle(selection.wrappedValue == nil ? Color.navText : Color.lightBlack)
                    .lineLimit(1)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 12).weight(.semibold))
                    .foregroundStyle(Color.navText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.boxbackground)
                    .stroke(Color.rectBorder, lineWidth: 1)
            )
        }
    }

    // Search + sort + filter result
    private var filteredVehicles: [VehicleModel] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        var result = viewModel.vehicles

        // Search by reg/make/model/
        if !q.isEmpty {
            result = result.filter {
                $0.registration.lowercased().contains(q) ||
                $0.make.lowercased().contains(q) ||
                $0.model.lowercased().contains(q) ||
                ("\($0.make) \($0.model)".lowercased().contains(q))
            }
        }

        // Filters
        if let filterMake { result = result.filter { $0.make == filterMake } }
        if let filterModel { result = result.filter { $0.model == filterModel } }
        if let filterColour { result = result.filter { $0.colour == filterColour } }
        if let filterFuel { result = result.filter { $0.fuelType == filterFuel } }

        // Sort
        let key: (VehicleModel) -> String = { "\($0.make) \($0.model)" }
        switch sortOption {
        case .az:
            result.sort { key($0).localizedCaseInsensitiveCompare(key($1)) == .orderedAscending }
        case .za:
            result.sort { key($0).localizedCaseInsensitiveCompare(key($1)) == .orderedDescending }
        }

        return result
    }

    var body: some View {
        NavigationStack{
            ZStack{
                VStack(spacing: 0){
                    VStack{
                        HStack {
                            Text("My Vehicles")
                                .foregroundStyle(.lightBlack)
                                .font(.system(size: 18).weight(.semibold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button {
                                viewModel.isShowingAddVehicle = true
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
                    .frame(maxWidth:.infinity, maxHeight: 64)
                    .background(Color.backgroundW)
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                    // Main content
                    GeometryReader{proxy in
                        VStack {
                            // If loading vehicles list
                            if viewModel.isLoading {
                                VStack {
                                    ProgressView("Finding vehicles...")
                                        .padding(.top, 20)
                                        .font(.system(size: 14))
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                
                                // If vehicles list is empty
                            } else if viewModel.vehicles.isEmpty {
                                VStack {
                                    VStack(spacing: 16){
                                        Image(systemName: "car.rear.hazardsign")
                                            .foregroundStyle(Color.redTheme)
                                            .font(.system(size: 50))
                                            .foregroundStyle(Color.black)
                                        
                                        Text("No Vehicles Found")
                                            .foregroundStyle(Color.lightBlack)
                                            .multilineTextAlignment(.center)
                                            .font(.system(size: 20, weight: .semibold))
                                        
                                        Text("Add your first vehicle to keep details, modifications and fuel history all in one place")
                                            .foregroundStyle(Color.bodyText)
                                            .multilineTextAlignment(.center)
                                            .font(.system(size: 14))
                                        
                                        HStack{
                                            HStack{
                                                Image(systemName: "clock")
                                                    .foregroundStyle(Color.redTheme)
                                                    .font(.system(size: 16))
                                                Text("Takes < 1 minute")
                                                    .font(.system(size: 13).weight(.regular))
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Color.rectBorder, lineWidth: 1)
                                            )
                                            HStack{
                                                Image(systemName: "lock")
                                                    .foregroundStyle(Color.redTheme)
                                                    .font(.system(size: 16))
                                                Text("Private")
                                                    .font(.system(size: 13).weight(.regular))
                                            }
                                            .padding(.horizontal, 24)
                                            .padding(.vertical, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Color.rectBorder, lineWidth: 1)
                                            )
                                        }
                                       
                                        Text("What you'll need:")
                                            .font(.system(size: 16).weight(.semibold))
                                        
                                        VStack(spacing: 8){
                                            HStack{
                                                Image(systemName: "checkmark.circle")
                                                    .foregroundStyle(Color.redTheme)
                                                Text("Vehicle Registration")
                                                    .font(.system(size: 14).weight(.regular))
                                            }
                                            HStack{
                                                Image(systemName: "checkmark.circle")
                                                    .foregroundStyle(Color.redTheme)
                                                Text("Vehicle Model")
                                                    . font(.system(size: 14).weight(.regular))
                                                    
                                            }
                                        }
                                        .padding(.top, 4)
                                        .padding(.bottom, 10)
                                        
                                        Button(action: {
                                            viewModel.isShowingAddVehicle = true
                                        }) {
                                            Text("Add Vehicle")
                                                .font(.system(size: 14).weight(.bold))
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color.redTheme)
                                                .foregroundColor(.white)
                                                .cornerRadius(100)
                                        }
                                    }
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    
                                }
                                .padding(.horizontal, 17)
                                .frame(maxWidth: .infinity,maxHeight: proxy.size.height - 42)
                                
                            // If there are vehicles
                            } else {
                                VStack(spacing: 18){
                                    // If there ar more than 4 vehicles show filter options
                                    if viewModel.vehicles.count > 4{
                                        VStack(spacing: 16){
                                            searchBar
                                            // Search + Sort
                                            HStack(spacing: 10) {
                                                sortPicker
                                                filtersHeaderRow
                                            }
                                            
                                            if showFilters {
                                                filtersExpanded
                                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                            }
                                        }
                                        .padding(.horizontal, 17)
                                        .offset(y: 16)
                                    }
                                    
                                    // If no filters match
                                    if filteredVehicles.isEmpty {
                                        VStack(spacing: 12){
                                            Image(systemName: "exclamationmark.magnifyingglass")
                                                .foregroundStyle(Color.redTheme)
                                                .font(.system(size: 34))
                                            
                                            Text("No vehicles match your search/filters.")
                                                .foregroundStyle(.bodyText)
                                                .multilineTextAlignment(.center)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                        
                                        // Display each vehicle
                                    }else{
                                        List() {
                                            ForEach(filteredVehicles.sorted {
                                                // Primary vehicles first
                                                ($0.isPrimary ? 0 : 1) < ($1.isPrimary ? 0 : 1)
                                            }
                                            ) { vehicle in
                                                VehicleCard(
                                                    vehicle: vehicle,
                                                    vehicleToDelete: $vehicleToDelete,
                                                    showDeleteConfirmation: $showDeleteConfirmation
                                                )
                                                .environmentObject(viewModel)
                                                .padding(.vertical, 10)
                                                .listRowInsets(.init())
                                                .listRowSeparator(.hidden)
                                                .listRowBackground(Color.clear)
                                                
                                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                                    Button(role: .destructive) {
                                                        vehicleToDelete = vehicle
                                                        showDeleteConfirmation = true
                                                    } label: {
                                                        Label("Delete", systemImage: "trash")
                                                    }
                                                    .tint(Color.redTheme)
                                                    Button {
                                                        viewModel.vehicleToEdit = vehicle
                                                        viewModel.isShowingEditVehicle = true
                                                    } label: {
                                                        Label("Edit", systemImage: "pencil")
                                                    }
                                                    .tint(.blue)

                                                }

                                                // Leading swipe action
                                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                                    if !vehicle.isPrimary {
                                                        Button {
                                                            Task {
                                                                await viewModel.makePrimary(vehicle)
                                                            }
                                                        } label: {
                                                            Label("Make Primary", systemImage: "star.fill")
                                                        }
                                                        .tint(.yellow)
                                                    }
                                                }

                                            }
                                            .padding(.horizontal, 17)
                                        }
                                        .listStyle(.plain)
                                        .refreshable {Task { await viewModel.loadVehicles() }}
                                        .scrollIndicators(.hidden)
                                    }
                                }
                                .frame(maxHeight: proxy.size.height - 42)
                            }
                        }
                    }
                    .alert("Delete Vehicle?", isPresented: $showDeleteConfirmation) {
                        Button("Delete", role: .destructive) {
                            Task {
                                if let vehicle = vehicleToDelete {
                                    await viewModel.deleteVehicle(vehicle)
                                }
                            }
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("Are you sure you want to delete this vehicle?")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .background(Color.background)
                    .navigationDestination(isPresented: $viewModel.showDetails) {
                        if let vehicle = viewModel.vehicleToPass {
                            VehicleDetailView(vehicle: vehicle)
                        }
                    }
                }
            }
        }
        .onAppear {
            Task { await viewModel.loadVehicles() }
        }
        .onChange(of: filterMake) { _ in
            // Avoid mismatched make/model combos
            filterModel = nil
        }
    }
}

struct VehicleCard: View {
    @EnvironmentObject var viewModel: VehicleViewModel

    let vehicle: VehicleModel
    @Binding var vehicleToDelete: VehicleModel?
    @Binding var showDeleteConfirmation: Bool

    var body: some View {
        Button{
            viewModel.vehicleToPass = vehicle
            viewModel.showDetails = true
        }label:{
            HStack{
                VStack(alignment: .leading, spacing: 18){
                    VStack(alignment: .leading, spacing: 2){
                        if vehicle.isPrimary {
                            Text("PRIMARY")
                                .font(.system(size: 12).weight(.bold))
                                .foregroundStyle(Color.redTheme)
                            
                        }
                        Text("\(vehicle.make) \(vehicle.model)")
                            .font(.system(size: 18).weight(.bold))
                            .foregroundStyle(Color.lightBlack)
                                            
                    }
                    
                    HStack(spacing: 14) {
                        Image(systemName: "drop.halffull")
                        Text("\(vehicle.fuelType)")
                            .textCase(.uppercase)
                                            
                        Image(systemName: "paintbrush")
                        Text("\(vehicle.colour)")
                            .textCase(.uppercase)
                    }
                    .font(.system(size: 12))
                    .foregroundStyle(Color.gray)
                    
                    HStack{
                        HStack{
                            Circle()
                                .fill(vehicle.motStatus == "Valid" ? Color.green : Color.redTheme)
                                    .frame(width: 8, height: 8)
                                
                                Text("Mot: \((vehicle.motStatus ?? "-"))")
                                    .font(.system(size: 10).weight(.medium))
                                    .foregroundStyle(Color.navText)
                                    .textCase(.uppercase)
                                    .tracking(-0.4)
                                
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.rectFill)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.rectBorder, lineWidth: 1)
                                )
                        )
                        
                        HStack{
                            Circle()
                                .fill(vehicle.taxStatus == "Taxed" ? Color.green : Color.redTheme)
                                    .frame(width: 8, height: 8)
                                
                                Text("Tax: \((vehicle.taxStatus ?? "-"))")
                                    .font(.system(size: 10).weight(.medium))
                                    .foregroundStyle(Color.navText)
                                    .textCase(.uppercase)
                                    .tracking(-0.4)
                                
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.rectFill)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.rectBorder, lineWidth: 1)
                                )
                        )
                    }
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .trailing, spacing: 20){
                    Text("\(vehicle.registration)")
                        .font(.system(size: 10).weight(.heavy))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 20)
                        .foregroundStyle(Color.black)
                        .frame(alignment: .trailing)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.black, lineWidth: 2)
                            .fill(Color.yellow)
                        )
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 26)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.rectBorder, lineWidth: 1)
                .fill(Color.boxbackground)
        )
    }
}

#Preview {
    VehicleView()
        .environmentObject(VehicleViewModel())
}

