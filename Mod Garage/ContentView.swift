//
//  ContentView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 20/10/2025.
//

import SwiftUI

struct SplashScreenView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isActive = false

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Image("Logo Light 1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
            }
            .opacity(isActive ? 0 : 1)
            .animation(.easeOut(duration: 0.5), value: isActive)
        }
        .onAppear {
            // Timer to transition away after 5 seconds (for testing)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation {
                    isActive = true
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}

