//
//  MainAppView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 23/10/2025.
//
import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var vehicleViewModel = VehicleViewModel()
    @StateObject private var detailViewModel = VehicleDetailViewModel()
    @StateObject private var fuelViewModel = FuelViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            
            // Main content area based on the selected tab
            Group {
                switch viewModel.selectedTab {
                case .home:
                    DashboardView(detailViewModel: detailViewModel)
                        .environmentObject(vehicleViewModel)
                case .vehicle:
                    VehicleView()
                        .environmentObject(vehicleViewModel)
                case .add:
                    DashboardView(detailViewModel: detailViewModel)
                        .environmentObject(vehicleViewModel)
                case .fuel:
                    FuelView()
                case .settings:
                    SettingsView()
                        .environmentObject(vehicleViewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .environmentObject(viewModel)
            .environmentObject(settingsViewModel)
            .preferredColorScheme(settingsViewModel.overrideColorScheme)
            
            // Shows the quick add overlay
            if viewModel.isShowingQuickAddMenu {
                ZStack {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring()) {
                                viewModel.isShowingQuickAddMenu = false
                            }
                        }

                    GeometryReader { geo in
                        let radius: CGFloat = min(geo.size.width, geo.size.height) / 3
                        let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

                        ZStack {
                            // Optional guide circle (commented out)
                            Circle().stroke(Color.white.opacity(0.8), lineWidth: 3).frame(width: radius * 2, height: radius * 2).position(center)

                            // Button at -60 degrees (upper-right on the arc)
                            Button {
                                withAnimation(.spring()) {
                                    viewModel.isShowingQuickAddMenu = false
                                    viewModel.selectedQuickAction = .modification
                                }
                            } label: {
                                quickActionRow(
                                    title: "Add Mod",
                                    systemImage: "wrench.and.screwdriver.fill"
                                )
                            }
                            .position(
                                x: center.x + radius * cos(CGFloat(-150) * .pi / 180),
                                y: center.y + radius * sin(CGFloat(-20) * .pi / 180)
                            )
                            
                            // Button at -60 degrees (upper-right on the arc)
                            Button {
                                withAnimation(.spring()) {
                                    viewModel.isShowingQuickAddMenu = false
                                    vehicleViewModel.isShowingAddVehicle = true
                                }
                            } label: {
                                quickActionRow(
                                    title: "Add Vehicle",
                                    systemImage: "car"
                                )
                            }
                            .position(
                                x: center.x + radius * cos(CGFloat(-90) * .pi / 180),
                                y: center.y + radius * sin(CGFloat(-120) * .pi / 180)
                            )

                            // Button at -120 degrees (upper-left on the arc)
                            Button {
                                withAnimation(.spring()) {
                                    viewModel.isShowingQuickAddMenu = false
                                    viewModel.selectedQuickAction = .fuelLog
                                }
                            } label: {
                                quickActionRow(
                                    title: "Add Fuel Log",
                                    systemImage: "fuelpump.fill"
                                )
                            }
                            .position(
                                x: center.x + radius * cos(CGFloat(30) * .pi / 180),
                                y: center.y + radius * sin(CGFloat(-20) * .pi / 180)
                            )
                        }
                        .offset(y: 300)
                    }
                    .frame(maxWidth: 350, maxHeight: .infinity, alignment: .bottom)
                }
                .transition(.opacity)
            }

            // The global navigation bar
            CustomTabBar(viewModel: viewModel)
            
            // Shows the add vehicle overlay
            if vehicleViewModel.isShowingAddVehicle{
                ZStack{
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.snappy) {
                                vehicleViewModel.isShowingAddVehicle = false
                            }
                        }

                    // Centered modal content
                    AddVehicleView(isPresented: $vehicleViewModel.isShowingAddVehicle)
                        .environmentObject(vehicleViewModel)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.containerBorder, lineWidth: 2)
                                .fill(Color.container)
                        )
                        .shadow(radius: 8)
                        .padding(.horizontal, 25)
                }
            }
            
            // Shows the edit vehicle overlay
            if vehicleViewModel.isShowingEditVehicle{
                ZStack{
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.snappy) {
                                vehicleViewModel.isShowingEditVehicle = false
                            }
                        }

                    if let vehicle = vehicleViewModel.vehicleToEdit {
                        EditVehicleView(vehicle: vehicle, isPresented: $vehicleViewModel.isShowingEditVehicle)
                            .environmentObject(vehicleViewModel)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.containerBorder, lineWidth: 2)
                                    .fill(Color.container)
                            )
                            .shadow(radius: 8)
                            .padding(.horizontal, 25)
                    } 
                }
            }
        }
        // Universal sheet shows content based on the type of quick action that is passed
        .sheet(item: $viewModel.selectedQuickAction, onDismiss: {
            Task {
                if let vehicleId = viewModel.primaryVehicle?.id {
                    await viewModel.loadModifications(vehicleId)
                    await viewModel.loadFuelLogs(vehicleId)
                }
            }
        }) { action in
            switch action {
            case .modification:
                if let vehicleId = viewModel.primaryVehicle?.id {
                    NavigationStack {
                        AddModificationView(vehicleId: vehicleId)
                            .environmentObject(detailViewModel)
                    }
                    .presentationDragIndicator(.visible)
                } else {
                    Text("No vehicle selected.")
                        .padding()
                }

            case .fuelLog:
                if let vehicleId = viewModel.primaryVehicle?.id{
                    NavigationStack {
                        AddFuelLogView(
                            vehicleId: vehicleId,
                            method: "fuel",
                            previousMileage: viewModel.latestFuelLogMileage
                        )
                        .environmentObject(fuelViewModel)
                    }
                    .presentationDragIndicator(.visible)
                } else {
                    Text("No vehicle selected.")
                        .padding()
                }
            }
        }
        .ignoresSafeArea( edges: .bottom)
    }
}

// Main home dashboard content
struct DashboardView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @EnvironmentObject var vehicleViewModel: VehicleViewModel
    @StateObject private var fuelViewModel = FuelViewModel()
    
    @Environment(\.openURL) private var openURL
    
    let detailViewModel: VehicleDetailViewModel
    
    var body: some View {
        VStack(spacing:0){
            VStack{
                HStack() {
                    // MARK: - If loading for first time show skeletal load for header
                    if viewModel.isProfileLoading {
                        // Profile picture
                        Circle()
                            .fill(Color.containerBorder)
                            .frame(width: 50, height: 50)
                            .redacted(reason: .placeholder)
                            .shimmer(speed: 1.6)

                        // Greeting and name
                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.containerBorder)
                                .frame(width: 90, height: 10)
                                .redacted(reason: .placeholder)
                                .shimmer(speed: 1.6)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.containerBorder)
                                .frame(width: 120, height: 14)
                                .redacted(reason: .placeholder)
                                .shimmer(speed: 1.6)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                    // MARK: - Otherwise show profile picture, greeting and name
                    } else {
                        
                        // Profile picture
                        if let photoURL = viewModel.profilePhotoURL {
                            AsyncImage(url: photoURL) { phase in
                                switch phase {
                                case .empty:
                                    Circle()
                                        .fill(Color.containerBorder)
                                        .frame(width: 50, height: 50)
                                        .redacted(reason: .placeholder)
                                        .shimmer(speed: 1.6)

                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())

                                case .failure(_):
                                    Image("profilePic")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())

                                @unknown default:
                                    Image("profilePic")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                }
                            }
                        } else {
                            Image("profilePic")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        }

                        // Greeting and name
                        VStack(spacing: 4) {
                            Text("Welcome Back!")
                                .font(.system(size: 12))
                                .tracking(-0.2)
                                .foregroundStyle(Color.containerText)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text(viewModel.name)
                                .padding(.leading, 1)
                                .font(.system(size: 18).weight(.semibold))
                                .fontWidth(.condensed)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Notifications button
                        Button {
                            viewModel.isShowingNotifications = true
                        } label: {
                            ZStack {
                                Image(systemName: "bell")
                                    .font(.system(size: 24))
                                    .foregroundStyle(Color.containerText)
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.containerBorder, lineWidth: 1)
                            )
                        }
                        
                    }
                }
            }
            .zIndex(30)
            .padding(.horizontal, 17)
            .padding(.bottom, 17)
            .frame(maxWidth: .infinity, maxHeight: 64)
            .background(Color.container)
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            
            GeometryReader{ proxy in
                VStack() {
                    // MARK: - If loading for first time show skeletal load for main content
                    if !viewModel.didRefreshOnThisLaunch {
                        ScrollView{
                            VStack(alignment: .leading, spacing: 16) {
                                // Vehicle image skeleton
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.containerBorder)
                                    .frame(height: 180)
                                    .redacted(reason: .placeholder)
                                    .shimmer(speed: 1.6)

                                // Two stat cards skeleton
                                HStack(spacing: 17) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.containerBorder)
                                        .frame(height: 150)
                                        .redacted(reason: .placeholder)
                                        .shimmer(speed: 1.6)
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.containerBorder)
                                        .frame(height: 150)
                                        .redacted(reason: .placeholder)
                                        .shimmer(speed: 1.6)
                                }

                                // Modifications title skeleton
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.containerBorder)
                                    .frame(width: 160, height: 14)
                                    .redacted(reason: .placeholder)
                                    .shimmer(speed: 1.6)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                // Modification cards skeleton list
                                HStack(spacing: 10) {
                                    ForEach(0..<3, id: \ .self) { _ in
                                        VStack(spacing: 8){
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color.containerBorder)
                                                .frame(width: 150, height: 150)
                                                .shimmer(speed: 1.6)
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color.containerBorder)
                                                .frame(width: 140, height: 14)
                                                .redacted(reason: .placeholder)
                                                .shimmer(speed: 1.6)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color.containerBorder)
                                                .frame(width: 150, height: 14)
                                                .redacted(reason: .placeholder)
                                                .shimmer(speed: 1.6)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 17)
                            .offset(y: 16)
                        }
                        
                    // MARK: - If there isn't a primary vehicle show an empty state
                    } else if viewModel.primaryVehicle == nil {
                        // Empty state when no vehicles
                        VStack(spacing: 16) {
                            // Illustration placeholder
                            Image(systemName: "door.garage.closed.trianglebadge.exclamationmark")
                                .font(.system(size: 48))
                                .foregroundStyle(Color.redTheme)
                            
                            // No vehicle title
                            Text("No vehicles yet")
                                .font(.system(size: 18, weight: .semibold))
                            
                            // Add vehicel prompt
                            Text("Add your first vehicle to track MOT, tax, fuel, and mods in one place.")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.containerText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)

                            // Add vehicle button
                            Button {
                                withAnimation(.spring()) {
                                    vehicleViewModel.isShowingAddVehicle = true
                                }
                            } label: {
                                Text("Add a Vehicle")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.redTheme)
                                    )
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 20)

                            // Value bullets
                            HStack(spacing: 12) {
                                Label("MOT & Tax reminders", systemImage: "bell.fill")
                                Label("Fuel insights", systemImage: "gauge.with.dots.needle.33percent")
                                Label("Mod log", systemImage: "wrench.and.screwdriver.fill")
                            }
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.containerText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                        }
                        .padding(.horizontal, 17)
                        
                    // MARK: - Otherwise show the main dashboard information for the primary vehicle
                    } else if let vehicle = viewModel.primaryVehicle {
                        // Main content
                        ScrollView{
                            VStack(spacing: 18){
                                
                                // Vehicle image
                                VStack(alignment: .leading, spacing: 4){
                                    Text("PRIMARY")
                                        .font(.system(size:10).weight(.bold))
                                        .foregroundStyle(Color.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.redTheme)
                                        )
                                    VStack(alignment: .leading, spacing: 8){
                                        Text("\(vehicle.year) " + "\(vehicle.make) " + "\(vehicle.model) ")
                                            .font(.system(size: 33).weight(.bold))
                                            .fontWidth(.condensed)
                                            .foregroundStyle(Color.white)
                                        
                                        GlassEffectContainer{
                                            VStack(alignment: .leading, spacing: 8){
                                                Text("REGISTRATION")
                                                    .font(.system(size: 8).weight(.semibold))
                                                    .tracking(-0.4)
                                                    .foregroundStyle(Color.white)
                                                Text("\(vehicle.registration)")
                                                    .font(.system(size: 14).weight(.bold))
                                                    .foregroundStyle(Color.white)
                                                    .multilineTextAlignment(.leading)
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            
                                        }
                                        .glassEffect(in: RoundedRectangle(cornerRadius: 8))
                                    }
                                   
                                    
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 30)
                                .frame(maxWidth: .infinity, maxHeight: 220, alignment: .bottomLeading)
                                .background(
                                    ZStack {
                                        if let urlString = vehicle.imageURL, let url = URL(string: urlString) {
                                            AsyncImage(url: url) { phase in
                                                switch phase {
                                                case .empty:
                                                    Rectangle()
                                                        .fill(Color.containerBorder)
                                                        .frame(maxWidth: .infinity, maxHeight: 220)
                                                        .redacted(reason: .placeholder)
                                                        .shimmer(speed: 1.6)
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(maxWidth: .infinity, maxHeight: 220)
                                                        .clipped()
                                                case .failure(_):
                                                    Image("carPlaceholder")
                                                        .resizable()
                                                        .frame(maxWidth: .infinity, maxHeight: 220)
                                                        .clipped()
                                                @unknown default:
                                                    Image("carPlaceholder")
                                                        .resizable()
                                                        .frame(maxWidth: .infinity, maxHeight: 220)
                                                        .clipped()
                                                }
                                            }
                                        } else {
                                            Image("carPlaceholder")
                                                .resizable()
                                                .frame(maxWidth: .infinity, maxHeight: 220)
                                                .clipped()
                                        }
                                    }
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                // MOT and Tax cards
                                HStack(spacing: 17) {
                                    // MOT
                                    VStack(alignment: .leading) {
                                        ZStack(alignment: .topTrailing) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.innerContainer)
                                                .frame(width: 40, height: 40)
                                                .overlay(
                                                    Image("mot")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 28, height: 28)
                                                        .foregroundStyle(Color.redTheme)
                                                )
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            HStack(spacing: 8) {
                                                PulsingCircle(
                                                        isValid: vehicle.motStatus == "Valid",
                                                        color: vehicle.motStatus == "Valid" ? .green : .redTheme
                                                )

                                                Text(vehicle.motStatus ?? "-")
                                                    .font(.system(size: 12).weight(.medium))
                                                    .fontWidth(.condensed)
                                            }
                                        }
                                        .padding(.bottom, 10)

                                        VStack(alignment: .leading, spacing: 10) {
                                            Text("MOT")
                                                .font(.system(size: 14).weight(.bold))
                                
                                            let date = viewModel.daysBetweenToday(date: vehicle.motExpiryDate)
                                            if date < 0{
                                                Text(" \(date * -1) Days Overdue")
                                                    .font(.system(size: 15).weight(.heavy))
                                                    .foregroundStyle(Color.redTheme)
                                                    .padding(-4)
                                            }
                                            else if date < 40{
                                                Text(" \(date) Days ")
                                                    .font(.system(size: 16).weight(.heavy))
                                                    .foregroundStyle(Color.orange)
                                                    .padding(-4)
                                            }
                                            else{
                                                Text(" \(date) Days ")
                                                    .font(.system(size: 16).weight(.heavy))
                                                    .foregroundStyle(Color.green)
                                                    .padding(-4)
                                            }
                                                
                                            if vehicle.motStatus == "Valid" {
                                                Text("Expires \(viewModel.dateFormatter(vehicle.motExpiryDate))")
                                                    .font(.system(size: 11))
                                                    .foregroundStyle(Color.containerText)
                                                    .tracking(-0.4)
                                            } else {
                                                Text("Expired \(viewModel.dateFormatter(vehicle.motExpiryDate))")
                                                    .font(.system(size: 11))
                                                    .foregroundStyle(Color.containerText)
                                                    .tracking(-0.4)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    }
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.containerBorder, lineWidth: 4)
                                            .fill(Color.container)
                                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 0)
                                    )
                                    
                                    // Tax
                                    VStack(alignment: .leading) {
                                        ZStack(alignment: .topTrailing) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.innerContainer)
                                                .frame(width: 40, height: 40)
                                                .overlay(
                                                    Image(systemName: "sterlingsign.arrow.trianglehead.counterclockwise.rotate.90")
                                                        .font(.system(size: 24, weight: .regular))
                                                        .scaledToFit()
                                                        .foregroundStyle(Color.redTheme)
                                                )
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            HStack(spacing: 8) {
                                                PulsingCircle(
                                                        isValid: vehicle.taxStatus == "Taxed",
                                                        color: vehicle.taxStatus == "Taxed" ? .green : .redTheme
                                                )

                                                Text(vehicle.taxStatus ?? "-")
                                                    .font(.system(size: 12).weight(.medium))
                                                    .fontWidth(.condensed)
                                            }
                                        }
                                        .padding(.bottom, 10)

                                        VStack(alignment: .leading, spacing: 10) {
                                            Text("Road Tax")
                                                .font(.system(size: 14).weight(.bold))
                                            
                                            if vehicle.taxStatus == "SORN"{
                                                Text("SORN")
                                                    .font(.system(size: 15).weight(.heavy))
                                                    .foregroundStyle(Color.orange)
                                                    .padding(-4)
                                                    .padding(.leading, 4)
                                                
                                                Button{
                                                    if let url = URL(string: "https://www.gov.uk/contact-the-dvla") {
                                                        openURL(url)
                                                    }
                                                }label:{
                                                    Text("Incorrect? Contact DVLA")
                                                }
                                                .foregroundStyle(Color.containerText)
                                                .font(.system(size: 11))
                                                .tracking(-0.4)
                                                
                                            }
                                            else{
                                                let date = viewModel.daysBetweenToday(date: vehicle.taxExpiryDate)
                                                if date < 0{
                                                    Text(" \(date * -1) Days Overdue")
                                                        .font(.system(size: 15).weight(.heavy))
                                                        .foregroundStyle(Color.redTheme)
                                                        .padding(-4)
                                                }
                                                else if date < 40{
                                                    Text(" \(date) Days ")
                                                        .font(.system(size: 16).weight(.heavy))
                                                        .foregroundStyle(Color.orange)
                                                        .padding(-4)
                                                }
                                                else{
                                                    Text(" \(date) Days ")
                                                        .font(.system(size: 16).weight(.heavy))
                                                        .foregroundStyle(Color.green)
                                                        .padding(-4)
                                                }

                                                if vehicle.taxStatus == "Taxed" {
                                                    Text("Expires \(viewModel.dateFormatter(vehicle.taxExpiryDate))")
                                                        .font(.system(size: 11))
                                                        .foregroundStyle(Color.containerText)
                                                        .tracking(-0.4)
                                                } else {
                                                    Text("Expired \(viewModel.dateFormatter(vehicle.taxExpiryDate))")
                                                        .font(.system(size: 11))
                                                        .foregroundStyle(Color.containerText)
                                                        .tracking(-0.4)
                                                }
                                            }
                                            
                                            
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    }
                                    .padding( 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.containerBorder, lineWidth: 4)
                                            .fill(Color.container)
                                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 0)
                                    )
                                }
                                
                                // Installed mods header
                                HStack{
                                    Text("Installed Mods")
                                        .font(.system(size: 18).weight(.semibold))
                                        .fontWidth(.condensed)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    // See all mods button
                                    if viewModel.modifications.count > 5 {
                                        Button{
                                            viewModel.isShowingAllMods = true
                                        }label:{
                                            Text("See All")
                                                .padding(.trailing, 10)
                                                .foregroundColor(.redTheme)
                                                .font(.system(size: 14).weight(.semibold))
                                                .fontWidth(.condensed)
                                                .frame(maxWidth: .infinity, alignment: .trailing)
                                        }
                                    }
                                }
                                
                                // If theere are mods list show 5
                                if !viewModel.modifications.isEmpty{
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(viewModel.modifications.prefix(5)) { mod in
                                                ModCard(modification: mod)
                                            }
                                        }
                                        .padding(.horizontal, 2)
                                        .padding(.vertical, 2)
                                    }
                                    
                                // Othewise show an empty sate box
                                } else {
                                    VStack(spacing: 8){
                                        ZStack{
                                            Circle()
                                                .fill(Color.containerBorder)
                                                .frame(width: 50, height: 50)
                                            
                                            Image(systemName: "wrench.and.screwdriver")
                                                .foregroundStyle(.redTheme)
                                        }
                                        Text("No Modifications Yet")
                                            .font(.system(size: 18).weight(.semibold))
                                            .fontWidth(.condensed)
                                            .frame(maxWidth: .infinity)
                                        
                                        // Add modification prompt
                                        Text("Add your first modification to personalise your build")
                                            .foregroundColor(.containerText)
                                            .font(.system(size: 12).weight(.medium))
                                            .frame(maxWidth: .infinity)
                                        
                                        // Add modification button
                                        Button{
                                            viewModel.selectedQuickAction = .modification
                                        }label:{
                                            Text("Add Modification")
                                            
                                        }
                                        .font(.system(size: 14).weight(.semibold))
                                        .fontWidth(.condensed)
                                        .foregroundStyle(Color.white)
                                        .padding(.horizontal,16)
                                        .padding(.vertical,10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color.redTheme)
                                        )
                                    }
                                    .padding(16)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.containerBorder, lineWidth: 4)
                                            .fill(Color.container)
                                            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)
                                    )
                                }
                                
                                // Recent fuel logs header
                                HStack{
                                    Text("Recent Fuel Logs")
                                        .font(.system(size: 18).weight(.semibold))
                                        .fontWidth(.condensed)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    // See all fuel logs button
                                    if viewModel.fuelLogs.count > 3 {
                                        Button{
                                            viewModel.isShowingAllLogs = true
                                        }label:{
                                            Text("See All")
                                                .padding(.trailing, 10)
                                                .foregroundColor(.redTheme)
                                                .font(.system(size: 14).weight(.semibold))
                                                .fontWidth(.condensed)
                                                .frame(maxWidth: .infinity, alignment: .trailing)
                                        }
                                    }
                                }
                                
                                // If theere are fuel logs list show 3
                                if !viewModel.fuelLogs.isEmpty{
                                    ForEach(viewModel.fuelLogs
                                        .sorted { $0.date > $1.date }
                                        .prefix(3)
                                    ) { fuelLog in
                                        FuelLogCard(
                                            fuelLog: fuelLog,
                                        )
                                        .environmentObject(fuelViewModel)
                                        .environmentObject(viewModel)
                                        
                                    }
                                }
                                // Otherwise show an empty state box
                                else{
                                    VStack(spacing: 8){
                                        ZStack{
                                            Circle()
                                                .fill(Color.containerBorder)
                                                .frame(width: 50, height: 50)
                                            
                                            Image(systemName: "fuelpump")
                                                .foregroundStyle(.redTheme)
                                        }
                                        Text("No Fuel logs Yet")
                                            .font(.system(size: 18).weight(.semibold))
                                            .fontWidth(.condensed)
                                        
                                        // Add modification prompt
                                        Text("Track your fuel purchases to see insights")
                                            .foregroundStyle(.containerText)
                                            .font(.system(size: 12).weight(.medium))
                                        
                                        // Add modification button
                                        Button{
                                            viewModel.selectedQuickAction = .fuelLog
                                        }label:{
                                            Text("Add Fuel Log")
                                        }
                                        .font(.system(size: 14).weight(.semibold))
                                        .fontWidth(.condensed)
                                        .foregroundStyle(Color.white)
                                        .padding(.horizontal,16)
                                        .padding(.vertical,10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color.redTheme)
                                        )
                                    }
                                    .padding(16)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.containerBorder, lineWidth: 4)
                                            .fill(Color.container)
                                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 0)
                                    )
                                }
                            }
                            .padding(.horizontal, 17)
                            .padding(.vertical, 16)
                        }
                        .scrollIndicators(.hidden)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: proxy.size.height - 84 )
            }
            // Multiple sheets to show the add modifcations/logs
            .sheet(isPresented:$viewModel.isShowingAllMods){
                ScrollView{
                    ForEach(viewModel.modifications
                        .sorted { $0.date > $1.date }
                    ) { modification in
                        ModificationCard(
                            detailVM: detailViewModel,
                            modification: modification,
                        )
                        .environmentObject(viewModel)
                        
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 36)
                }
                .frame(maxWidth: .infinity)
                .background(Color.background)
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented:$viewModel.isShowingAllLogs){
                ScrollView{
                    ForEach(viewModel.fuelLogs
                        .sorted { $0.date > $1.date }
                    ) { fuelLog in
                        FuelLogCard(
                            fuelLog: fuelLog,
                        )
                        .environmentObject(viewModel)
                        .environmentObject(fuelViewModel)
                        
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 36)
                }
                .frame(maxWidth: .infinity)
                .background(Color.background)
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $viewModel.isShowingNotifications) {
                NavigationStack {
                    NotificationView(viewModel: NotificationViewModel(vehicleProvider: {
                        vehicleViewModel.vehicles
                    }))
                }
                .presentationDragIndicator(.visible)
            }
            .onAppear {
                Task {
                    await viewModel.loadVehicleData()
                    if let vehicleId = viewModel.primaryVehicle?.id {
                        await viewModel.loadModifications(vehicleId)
                        await viewModel.loadFuelLogs(vehicleId)
                    }
                }
            }
        }
    }
}

// Resuable pulsing circle for MOT and Tax
struct PulsingCircle: View {
    var isValid: Bool
    var color: Color

    @State private var animate = false

    var body: some View {
        ZStack {
            // Inner constant dot
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .shadow(
                    color: !isValid ? color.opacity(0.6) : .clear,
                    radius: !isValid ? 6 : 0
                )

            // Outward pulsing ring
            Circle()
                .stroke(color.opacity(0.9), lineWidth: 2)
                .frame(width: 8, height: 8)
                .scaleEffect(animate ? 2.0 : 1.0)
                .opacity(animate ? 0.0 : (isValid ? 0.6 : 0.9))
                .animation(animation, value: animate)
        }
        .onAppear {
            animate = true
        }
    }

    // Animation picker
    private var animation: Animation {
        if isValid {
            return .easeOut(duration: 2).repeatForever(autoreverses: false)
        } else {
            return .easeOut(duration: 0.8).repeatForever(autoreverses: false)
        }
    }
}

// Reuable buttons within the quick add overlay
@ViewBuilder
private func quickActionRow(title: String, systemImage: String) -> some View {
    VStack(spacing: 10) {
        ZStack {
            Circle()
                .fill(Color.container)
                .frame(width: 52, height: 52)

            Image(systemName: systemImage)
                .font(.system(size: 16))
                .foregroundStyle(Color.redTheme)
        }

        Text(title)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Color.container)
            .shadow(radius: 1)

    }
    .padding()
    .frame(maxWidth: 160, maxHeight: 50)
}

// Resuable card for displaying modifcation information
struct ModCard: View {
    let modification: ModificationModel

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            ZStack {
                // Vehicle image
                if let urlString = modification.afterImageURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.containerBorder)
                                .frame(width: 150, height: 150)
                                .redacted(reason: .placeholder)
                                .shimmer(speed: 1.6)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                        case .failure(_):
                            ZStack{
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.innerContainer)
                                    .frame(width: 150, height: 150)
                                
                                Image(systemName: "wrench.and.screwdriver.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.redTheme)
                            }
                        @unknown default:
                            ZStack{
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.innerContainer)
                                    .frame(width: 150, height: 150)
                                
                                Image(systemName: "wrench.and.screwdriver.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.redTheme)
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    ZStack{
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.innerContainer)
                            .frame(width: 150, height: 150)
                            .redacted(reason: .placeholder)
                        
                        Image(systemName: "wrench.and.screwdriver.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.redTheme)
                    }
                }
            }
            
            // Mod name and description
            VStack(alignment: .center, spacing: 4) {
                Text(modification.name)
                    .font(.system(size: 18, weight: .semibold))
                    .fontWidth(.condensed)
                    .multilineTextAlignment(.center)
                    .frame(width: 140, alignment: .center)

                Text(modification.description ?? "")
                    .font(.system(size: 14))
                    .fontWidth(.condensed)
                    .foregroundStyle(Color.containerText)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .frame(width: 150, alignment: .center)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        
    }
}

// Shimmer for skeletal load
extension View {
    func shimmer(speed: Double = 1.2) -> some View {
        modifier(GradientShimmer(speed: speed))
    }
}
private struct GradientShimmer: ViewModifier {
    @State private var phase: CGFloat = -1
    let speed: Double

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { proxy in
                    let size = proxy.size
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.container.opacity(0.0),
                            Color.container.opacity(0.6),
                            Color.container.opacity(0.0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: size.width * 0.6, height: size.height)
                    .offset(x: phase)
                    .onAppear {
                        phase = -size.width
                        withAnimation(.linear(duration: speed).repeatForever(autoreverses: false)) {
                            phase = size.width * 2
                        }
                    }
                }
                .mask(content)
            )
    }
}

// Preview
#Preview {
    HomeView()
        .environmentObject(AppViewModel())
}

