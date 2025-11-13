//
//  ProfileView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 13/11/2025.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Profile")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Edit your profile.")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
