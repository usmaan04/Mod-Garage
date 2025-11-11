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
            .background(Color(.systemBackground))

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
                VStack(spacing: 6){
                    Text("Welcome back!")
                        .font(.system(size: 11))
                        .foregroundColor(Color.bodyText)
                        .frame(maxWidth: .infinity,alignment: .leading)

                    if viewModel.name.isEmpty {
                        ProgressView("Loading...")
                            .padding()
                    } else {
                        Text("\(viewModel.name)!")
                            .font(.system(size: 16))
                            .foregroundColor(Color.black)
                            .frame(maxWidth: .infinity,alignment: .leading)
                    }
                    
                }
            }
        }
        .padding(.horizontal, 8)
        .background(Color(.background))
        .frame(maxWidth: .infinity, maxHeight: .infinity ,alignment: .top)
    }
}

// Preview
#Preview {
    HomeView()
        .environmentObject(AppViewModel())
}
