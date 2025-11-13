//
//  ContentView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 20/10/2025.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            AppView()
        } else {
            ZStack {
                VStack(spacing: 20) {
                    Image("AdaptiveLaunch")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                }
                .opacity(isActive ? 0 : 1)
                .animation(.easeOut(duration: 0.5), value: isActive)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
