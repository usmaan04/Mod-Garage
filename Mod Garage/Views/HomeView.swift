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
                    DashboardView()
                        .environmentObject(vehicleViewModel)
                case .vehicle:
                    VehicleView()
                        .environmentObject(vehicleViewModel)
                case .add:
                    DashboardView()
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
                            Circle().stroke(Color.white.opacity(0.6), lineWidth: 1).frame(width: radius * 2, height: radius * 2).position(center)

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

            CustomTabBar(viewModel: viewModel)
            
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
                                .stroke(Color.rectBorder, lineWidth: 2)
                                .fill(Color.boxbackground)
                        )
                        .shadow(radius: 8)
                        .padding(.horizontal, 25)
                }
            }
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
                                    .stroke(Color.rectBorder, lineWidth: 2)
                                    .fill(Color.boxbackground)
                            )
                            .shadow(radius: 8)
                            .padding(.horizontal, 25)
                    } 
                }
            }
        }
        .sheet(item: $viewModel.selectedQuickAction, onDismiss: {
            Task {
                await viewModel.refreshRecentActivity()
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

struct DashboardView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @EnvironmentObject var vehicleViewModel: VehicleViewModel
    var body: some View {
        VStack(spacing:0){
            VStack{
                HStack() {
                    if viewModel.isProfileLoading {
                        Circle()
                            .fill(Color.rectBorder)
                            .frame(width: 50, height: 50)
                            .redacted(reason: .placeholder)
                            .shimmer(speed: 1.6)

                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.rectBorder)
                                .frame(width: 90, height: 10)
                                .redacted(reason: .placeholder)
                                .shimmer(speed: 1.6)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.rectBorder)
                                .frame(width: 120, height: 14)
                                .redacted(reason: .placeholder)
                                .shimmer(speed: 1.6)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } else {
                        if let photoURL = viewModel.profilePhotoURL {
                            AsyncImage(url: photoURL) { phase in
                                switch phase {
                                case .empty:
                                    Circle()
                                        .fill(Color.rectBorder)
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
                                    Image("AdaptiveLaunch")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())

                                @unknown default:
                                    Image("AdaptiveLaunch")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                }
                            }
                        } else {
                            Image("AdaptiveLaunch")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        }

                        VStack(spacing: 4) {
                            Text("Welcome Back!")
                                .font(.system(size: 12))
                                .tracking(-0.2)
                                .foregroundStyle(Color.bodyText)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text(viewModel.name)
                                .font(.system(size: 16).weight(.semibold))
                                .foregroundStyle(Color.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Button {
                            print("notif")
                        } label: {
                            ZStack {
                                Image(systemName: "bell")
                                    .font(.system(size: 24))
                                    .foregroundStyle(Color.navText.opacity(0.8))
                                
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 8)
                                    .offset(x: 6, y: -8)
                                    .overlay(
                                        Circle()
                                            .fill(Color.redTheme)
                                            .frame(width: 6)
                                            .offset(x: 6, y: -8)
                                    )
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.rectBorder, lineWidth: 1)
                            )
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
                VStack() {
                    if !viewModel.didRefreshOnThisLaunch {
                        ScrollView{
                            VStack(spacing: 16) {
                                // If loading skeletal load
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.rectBorder)
                                    .frame(height: 220)
                                    .redacted(reason: .placeholder)
                                    .shimmer(speed: 1.6)
                                    .padding(.horizontal, 17)

                                // MOT and Tax title skeleton
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.rectBorder)
                                    .frame(width: 140, height: 14)
                                    .redacted(reason: .placeholder)
                                    .shimmer(speed: 1.6)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 17)

                                // Two stat cards skeleton
                                HStack(spacing: 17) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.rectBorder)
                                        .frame(height: 150)
                                        .redacted(reason: .placeholder)
                                        .shimmer(speed: 1.6)
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.rectBorder)
                                        .frame(height: 150)
                                        .redacted(reason: .placeholder)
                                        .shimmer(speed: 1.6)
                                }
                                .padding(.horizontal, 17)

                                // Recent activity title
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.rectBorder)
                                    .frame(width: 160, height: 14)
                                    .redacted(reason: .placeholder)
                                    .shimmer(speed: 1.6)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 17)

                                // Recent cards skeleton list
                                VStack(spacing: 10) {
                                    ForEach(0..<3, id: \ .self) { _ in
                                        RoundedRectangle(cornerRadius: 26)
                                            .fill(Color.rectBorder)
                                            .frame(height: 84)
                                            .redacted(reason: .placeholder)
                                            .shimmer(speed: 1.6)
                                    }
                                }
                                .padding(.horizontal, 17)
                            }
                            .offset(y: 16)
                        }
                    } else if viewModel.primaryVehicle == nil {
                        // Empty state when no vehicles
                        VStack(spacing: 16) {
                            // Illustration placeholder
                            Image(systemName: "door.garage.closed.trianglebadge.exclamationmark")
                                .font(.system(size: 48))
                                .foregroundStyle(Color.redTheme)
                            
                            Text("No vehicles yet")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color.lightBlack)
                            
                            Text("Add your first vehicle to track MOT, tax, fuel, and mods in one place.")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.navText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)

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

                            // Optional value bullets
                            HStack(spacing: 12) {
                                Label("MOT & Tax reminders", systemImage: "bell.fill")
                                Label("Fuel insights", systemImage: "gauge.with.dots.needle.33percent")
                                Label("Mod log", systemImage: "wrench.and.screwdriver.fill")
                            }
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.navText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                        }
                        .padding(.horizontal, 17)
                        
                    } else if let vehicle = viewModel.primaryVehicle {
                        // Main content
                        ScrollView{
                            VStack(spacing: 16){
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
                                            .font(.system(size: 26).weight(.bold))
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
                                        Image("carimg")
                                            .resizable()
                                            .frame(maxWidth: .infinity, maxHeight: 220)
                                            .clipped()
                                        Rectangle()
                                            .fill(Color.black.opacity(0.3))
                                            .frame(maxWidth: .infinity, maxHeight: 220)
                                    }
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                HStack(spacing: 17) {
                                    VStack(alignment: .leading) {
                                        ZStack(alignment: .topTrailing) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.lightPink)
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
                                                    .font(.system(size: 10).weight(.medium))
                                                    .foregroundStyle(Color.lightBlack)
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
                                                    .foregroundStyle(Color.bodyText)
                                                    .tracking(-0.4)
                                            } else {
                                                Text("Expired \(viewModel.dateFormatter(vehicle.motExpiryDate))")
                                                    .font(.system(size: 11))
                                                    .foregroundStyle(Color.bodyText)
                                                    .tracking(-0.4)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    }
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.rectBorder, lineWidth: 4)
                                            .fill(Color.boxbackground)
                                    )
                                    VStack(alignment: .leading) {
                                        ZStack(alignment: .topTrailing) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.lightPink)
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
                                                    .font(.system(size: 10).weight(.medium))
                                                    .foregroundStyle(Color.lightBlack)
                                            }
                                        }
                                        .padding(.bottom, 10)

                                        VStack(alignment: .leading, spacing: 10) {
                                            Text("Road Tax")
                                                .font(.system(size: 14).weight(.bold))
                                            
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
                                                    .foregroundStyle(Color.bodyText)
                                                    .tracking(-0.4)
                                            } else {
                                                Text("Expired \(viewModel.dateFormatter(vehicle.taxExpiryDate))")
                                                    .font(.system(size: 11))
                                                    .foregroundStyle(Color.bodyText)
                                                    .tracking(-0.4)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    }
                                    .padding( 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.rectBorder, lineWidth: 4)
                                            .fill(Color.boxbackground)
                                    )
                                }
                                
                                Text("Recent Activity")
                                    .foregroundStyle(.lightBlack)
                                    .font(.system(size: 16).weight(.semibold))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if !viewModel.recentActivity.isEmpty{
                                    
                                    VStack(spacing: 10){
                                        ForEach(viewModel.recentActivity.prefix(3)) { item in
                                            switch item {
                                            case .modification(let mod):
                                                RecentCard(modification: mod, fuelLog: nil)
                                                    .environmentObject(viewModel)
                                                
                                            case .fuel(let log):
                                                RecentCard(modification: nil, fuelLog: log)
                                                    .environmentObject(viewModel)
                                            }
                                        }
                                    }
                                }
                                else{
                                    VStack{
                                        
                                    }
                                    .padding(16)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.rectBorder, lineWidth: 4)
                                            .fill(Color.boxbackground)
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
            .onAppear {
                Task {
                    await viewModel.loadVehicleData()
                    await viewModel.refreshRecentActivity()
                }
            }
        }
    }
}

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

@ViewBuilder
private func quickActionRow(title: String, systemImage: String) -> some View {
    VStack(spacing: 10) {
        ZStack {
            Circle()
                .fill(Color.boxbackground)
                .frame(width: 52, height: 52)

            Image(systemName: systemImage)
                .font(.system(size: 16))
                .foregroundStyle(Color.redTheme)
        }

        Text(title)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Color.backgroundW)
            .shadow(radius: 1)

    }
    .padding()
    .frame(maxWidth: 160, maxHeight: 50)
}

struct RecentCard: View{
    let modification: ModificationModel?
    let fuelLog: FuelLogModel?
    
    @EnvironmentObject var viewModel: HomeViewModel
    
    var body: some View{
        if let mod = modification {
            HStack(spacing: 20) {
                ZStack{
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.lightPink)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(Color.redTheme)
                }
                
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack() {
                        Text(mod.name)
                            .font(.system(size: 16).weight(.bold))
                            .foregroundStyle(Color.lightBlack)
                            .multilineTextAlignment(.leading)
                        
                        Text(viewModel.modDateFormatter(mod.date))
                            .font(.system(size: 12).weight(.medium))
                            .foregroundStyle(Color.navText)
                            .frame(maxWidth:. infinity, alignment: .trailing)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if let desc = mod.description, !desc.isEmpty {
                        Text(desc)
                            .font(.system(size: 12).weight(.medium))
                            .foregroundStyle(Color.navText)
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .frame(maxWidth:. infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 26)
                    .stroke(Color.rectBorder, lineWidth: 2)
                    .fill(Color.boxbackground)
            )
        } else if let log = fuelLog {
            HStack(spacing: 20) {
                ZStack{
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.lightPink)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "fuelpump.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(Color.redTheme)
                }
                VStack(alignment: .leading, spacing: 4) {
                    HStack{
                        Text("Fuel Fill-Up")
                            .font(.system(size: 16).weight(.bold))
                            .foregroundStyle(Color.lightBlack)
                                                    
                        Text(viewModel.modDateFormatter(log.date))
                            .font(.system(size: 12).weight(.medium))
                            .foregroundStyle(Color.navText)
                            .frame(maxWidth:. infinity, alignment: .trailing)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("\(String(format: "%.2f", log.litres))L @ \(log.location)")
                        .font(.system(size: 12).weight(.medium))
                        .foregroundStyle(Color.navText)
                }
                
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .frame(maxWidth:. infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 26)
                    .stroke(Color.rectBorder, lineWidth: 2)
                    .fill(Color.boxbackground)
            )
        }
    }
}

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
                            Color.white.opacity(0.0),
                            Color.white.opacity(0.6),
                            Color.white.opacity(0.0)
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

