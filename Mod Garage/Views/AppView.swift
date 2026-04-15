//
//  AppView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 23/10/2025.
//

import SwiftUI

struct AppView: View {
    @StateObject private var viewModel = AppViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()

    var body: some View {
        Group {
            // if user is logged in and onboarding has been completd show home
            if viewModel.isUserLoggedIn && viewModel.hasCompletedOnboarding {
                HomeView()
                    .transition(.opacity)
            // Else show authentication (SignUp and Login)
            } else {
                AuthView(isUserLoggedIn: $viewModel.isUserLoggedIn, hasCompletedOnboarding: $viewModel.hasCompletedOnboarding)
                    .transition(.opacity)
            }
        }
        .environmentObject(viewModel)
    }
}
