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
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome to Mod Garage!")
                    .font(.title)

                if viewModel.name.isEmpty {
                    ProgressView("Loading...")
                        .padding()
                } else {
                    Text("Welcome, \(viewModel.name)!")
                        .font(.title2)
                        .fontWeight(.semibold)
                }

                Button(action: appViewModel.signOut) {
                    Text("Log Out")
                        .frame(maxWidth: 250)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
            }
            .navigationTitle("Home")
        }
    }
}
