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
        VStack {
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
            .padding(.horizontal, 17)
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
                                .stroke(Color.black, lineWidth: 1)
                                .fill(Color.yellow)
                        )
                        
                    HStack(spacing: 15){
                        Image(systemName: "drop.halffull")
                            .font(.system(size: 16))
                        Text("\(vehicle.fuelType)")
                        Divider()
                            .background(Color.rectBorder)
                            .frame(maxWidth: 1, maxHeight: 20)
                        Image(systemName: "paintbrush")
                            .font(.system(size: 16))
                        Text("\(vehicle.colour)")
                    }
                    .font(.system(size: 14))
                    .foregroundStyle(Color.navText)
                }
                .padding(.horizontal,17)
                .frame(maxWidth: .infinity, maxHeight: 170, alignment: .leading)
                .background(Color.rectFill)
                
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
                                        .frame(width: 24, height: 24)
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
                .padding(.horizontal, 17)
            
            } else {
                Text("Add a vehicle")
            }
            
        }
        .padding(.top, 14)
        .frame(maxWidth: .infinity, maxHeight: .infinity ,alignment: .top)
        .onAppear {
            Task {
                await viewModel.loadVehicleData()
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

// Preview
#Preview {
    HomeView()
        .environmentObject(AppViewModel())
}
