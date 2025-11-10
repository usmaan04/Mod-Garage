//
//  AppView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 23/10/2025.
//

import SwiftUI

struct AppView: View {
    @StateObject private var viewModel = AppViewModel()

    var body: some View {
        Group {
            if viewModel.isUserLoggedIn {
                HomeView()
                    .transition(.opacity)
            } else {
                AuthView(isUserLoggedIn: $viewModel.isUserLoggedIn)
                    .transition(.opacity)
            }
        }
        .environmentObject(viewModel)
    }
}
