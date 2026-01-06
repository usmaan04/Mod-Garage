//
//  VehicleDetailView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 06/01/2026.
//

import SwiftUI

struct VehicleDetailView: View {
    
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
                    
                }
            }
            .padding(.horizontal, 17)
        }
    }
}
