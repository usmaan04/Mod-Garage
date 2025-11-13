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
                case .profile:
                    ProfileView()
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
                VStack(spacing: 6){
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
                            .font(.system(size: 20).weight(.semibold))
                            .foregroundColor(Color.black)
                            .frame(maxWidth: .infinity,alignment: .leading)
                    }
                    
                }
            }
        }
        .padding(.horizontal, 17)
        .padding(.top, 14)
        .frame(maxWidth: .infinity, maxHeight: .infinity ,alignment: .top)
    }
}

// Preview
#Preview {
    HomeView()
        .environmentObject(AppViewModel())
}
