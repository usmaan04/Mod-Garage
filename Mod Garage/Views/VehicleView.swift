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
        
        ZStack {
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
                
                VStack(){
                    Text("Manage your vehicles here.")
                        .foregroundStyle(.secondary)
                }
                .frame(maxHeight: 600, alignment: .center)
            }
            .padding(.horizontal, 17)
            .padding(.top, 14)
            .frame(maxWidth: .infinity, maxHeight: .infinity ,alignment: .top)
            
            // Modal
            if viewModel.isShowingAddVehicle {
                
                // Dimmed background
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        viewModel.isShowingAddVehicle = false
                    }
                
                // Centered popup wrapper
                VStack {
                    AddVehicleView(isPresented: $viewModel.isShowingAddVehicle)
                        .environmentObject(viewModel)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.rectBorder, lineWidth: 2)
                                .fill(Color.background)
                        )
                        
                        .shadow(radius: 8)
                        .padding(.horizontal, 25)

                }
                .frame(maxWidth: 350, maxHeight: 150)
                .transition(.scale(scale: 2))
                
                
            }
        }
    }
}

// Preview
#Preview {
    VehicleView()
}

