//
//  FuelView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 11/11/2025.
//

import Foundation
import SwiftUI

struct FuelView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Fuel")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Track your fuel and costs.")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
