//
//  SettingsView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 11/11/2025.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Settings")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Configure app preferences.")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
