//
//  VehicleView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 11/11/2025.
//
import Foundation
import SwiftUI

struct VehicleView: View {
    @StateObject private var viewModel = VehicleViewModel()
    
    var body: some View {
        VStack(spacing: 12) {
            HStack{
                Text("My Vehicles")
                    .foregroundColor(.black)
                    .font(.system(size: 18).weight(.semibold))
                    .frame(maxWidth: .infinity,alignment: .leading)
                Button {
                    viewModel.isShowingAddVehicle = true
                } label: {
                    ZStack {
                        // Red circle
                        Circle()
                            .fill(Color.redTheme)
                            .frame(width: 46, height: 46)

                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            
            VStack{
                Text("Manage your vehicles here.")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 17)
        .padding(.top, 14)
        .frame(maxWidth: .infinity, maxHeight: .infinity ,alignment: .top)
        .sheet(isPresented: $viewModel.isShowingAddVehicle) {
            AddVehicleView()
        }
    }
}

// Preview
#Preview {
    VehicleView()
}

