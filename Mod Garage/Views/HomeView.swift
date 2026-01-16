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

    var body: some View {
        ZStack(alignment: .bottom) {
            
            // Main content area based on the selected tab
            Group {
                switch viewModel.selectedTab {
                case .home:
                    DashboardView()
                case .vehicle:
                    VehicleView()
                case .add:
                    SettingsView()
                case .fuel:
                    FuelView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.background))
            .environmentObject(viewModel)
            .environmentObject(settingsViewModel)
            .preferredColorScheme(settingsViewModel.overrideColorScheme)

            CustomTabBar(viewModel: viewModel)
        }
        .ignoresSafeArea( edges: .bottom)
    }
}

struct DashboardView: View {
    @StateObject private var viewModel = HomeViewModel()
    var body: some View {
        VStack(spacing: 12) {
            HStack() {
                Image("AdaptiveLaunch")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                VStack(spacing: 4){
                    Text("Welcome Back!")
                        .font(.system(size: 12))
                        .tracking(-0.2)
                        .foregroundColor(Color.bodyText)
                        .frame(maxWidth: .infinity,alignment: .leading)

                    if viewModel.name.isEmpty {
                        ProgressView("Loading...")
                            .padding()
                    } else {
                        Text("\(viewModel.name)")
                            .font(.system(size: 16).weight(.semibold))
                            .foregroundColor(Color.black)
                            .frame(maxWidth: .infinity,alignment: .leading)
                    }
                    
                }
            }
            if let vehicle = viewModel.primaryVehicle {
                VStack(alignment: .leading, spacing: 22){
                    Text("\(vehicle.make) " + "\(vehicle.model) ")
                        .font(.system(size: 20).weight(.bold))
                        .foregroundStyle(Color.lightBlack)
                    
                    Text("\(vehicle.registration)")
                        .font(.system(size: 15).weight(.bold))
                        .padding(.vertical,6)
                        .padding(.horizontal,20)
                        .foregroundStyle(Color.black)
                        .background(
                            RoundedRectangle(cornerRadius: 1)
                                .stroke(Color.black, lineWidth: 3)
                                .fill(Color.yellow)
                        )
                }
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: 140, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.rectFill)
                )
                
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

                        VStack(alignment: .leading, spacing: 8) {
                            Text("MOT")
                                .font(.system(size: 12).weight(.medium))

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
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.rectBorder, lineWidth: 1)
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
                                        .foregroundColor(Color.redTheme)
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

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Road Tax")
                                .font(.system(size: 12).weight(.medium))

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
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.rectBorder, lineWidth: 1)
                    )
                }
                .padding(.top, 12)
                
                Text("Recent Activity")
                    .foregroundColor(.lightBlack)
                    .font(.system(size: 17).weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                List {
                    ForEach(viewModel.modifications.sorted { $0.createdAt > $1.createdAt
                    }
                    ) { modification in
                        ModificationCard(
                            modification: modification,
                        )
                        .environmentObject(viewModel)
                        .padding(.vertical, 10)
                        .listRowInsets(.init())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
            
            } else {
                Text("Add a vehicle")
            }
            
        }
        .padding(.horizontal, 17)
        .frame(maxWidth: .infinity, maxHeight: .infinity ,alignment: .top)
        .onAppear {
            Task {
                await viewModel.loadVehicleData()
                if let vehicleID = viewModel.primaryVehicle?.id, !vehicleID.isEmpty {
                    await viewModel.loadModifications(vehicleID)
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
        Circle()
            .fill(color)
            .frame(width: 6, height: 6)
            .scaleEffect(isValid && animate ? 1.4 : 1.0)
            .shadow(
                color: !isValid ? color.opacity(animate ? 1.6 : 0.3) : .clear,
                radius: !isValid ? (animate ? 6 : 6) : 0
            )
        
            .animation(animation, value: animate)
            .onAppear {
                animate = true
            }
    }

    // Animation picker
    private var animation: Animation {
        if isValid {
            return .easeInOut(duration: 1.5).repeatForever(autoreverses: true)
        } else {
            return .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
        }
    }
}

struct ModificationCard: View {
    @EnvironmentObject var viewModel: HomeViewModel

    let modification: ModificationModel

    var body: some View {
        HStack{
            ZStack{
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.rectFill)
                    .frame(width:46, height: 46)
                
                switch modification.type {
                case "Exhaust":
                    Image(systemName: "pipe.and.drop.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.redTheme)
                case "Windows":
                    Image(systemName: "car.window.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.redTheme)
                case "Lights":
                    Image(systemName: "lightbulb.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.redTheme)
                case "Engine":
                    Image(systemName: "engine.combustion.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.redTheme)
                case "Bodykit":
                    Image(systemName: "car.side.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.redTheme)
                default:
                    Image(systemName: "car.side.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.redTheme)
                }
            }
            VStack(alignment: .leading, spacing: 4){
                Text(modification.name)
                    .font(.system(size: 14).weight(.medium))
                    .foregroundStyle(Color.lightBlack)
                Text(viewModel.modDateFormatter(modification.createdAt))
                    .font(.system(size: 11))
                    .foregroundStyle(Color.bodyText)
                    .tracking(-0.4)

            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.rectBorder, lineWidth: 1)
        )
    }
}

// Preview
#Preview {
    HomeView()
        .environmentObject(AppViewModel())
}
