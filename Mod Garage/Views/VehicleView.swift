//
//  VehicleView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 11/11/2025.
//
import Foundation
import SwiftUI

struct VehicleView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Vehicles")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Manage your vehicles here.")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
