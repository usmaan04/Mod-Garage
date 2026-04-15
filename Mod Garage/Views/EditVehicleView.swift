//
//  AddVehicleView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 15/11/2025.
//

import Foundation
import SwiftUI

struct EditVehicleView: View {
    let vehicle: VehicleModel
    @Binding var isPresented: Bool
    @StateObject var viewModel: EditVehicleViewModel
    @EnvironmentObject var vehicleViewModel: VehicleViewModel

    init(vehicle: VehicleModel, isPresented: Binding<Bool>) {
        self.vehicle = vehicle
        self._isPresented = isPresented
        _viewModel = StateObject(wrappedValue: EditVehicleViewModel(vehicle: vehicle))
    }

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 24){
                Text("Edit Vehicle")
                    .font(.system(size: 17).weight(.bold))
                    .padding(.bottom,6)
                
                HStack{
                    VStack(spacing: 8){
                        Text("Model")
                            .font(.system(size: 14).weight(.medium))
                        TextField(
                            "",
                            text: $viewModel.model,
                            prompt: Text("Enter Model")
                                .foregroundStyle(.black.opacity(0.3))
                        )
                        .font(.system(size: 12))
                        .padding(.vertical, 16)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.container)
                                .stroke(Color.containerBorder, lineWidth: 1)
                        )
                    }
                    
                    VStack(spacing: 8){
                        Text("Colour")
                            .font(.system(size: 14).weight(.medium))
                        TextField(
                            "",
                            text: $viewModel.colour,
                            prompt: Text("Enter Colour")
                                .foregroundStyle(.black.opacity(0.3))
                        )
                        .font(.system(size: 12))
                        .padding(.vertical, 16)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.container)
                                .stroke(Color.containerBorder, lineWidth: 1)
                        )
                    }
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 8)
                        .multilineTextAlignment(.center)
                }
                
                HStack{
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .font(.system(size: 10).weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .foregroundColor(.redTheme)
                    }
                    
                    .background(
                        RoundedRectangle(
                            cornerRadius: 12,
                            style: .continuous
                        )
                        .stroke(Color.containerBorder)
                    )
                
                    Button(action: {
                        viewModel.saveChanges()
                    }) {
                        Text("Save")
                            .font(.system(size: 10).weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .foregroundColor(.white)
                    }
                    .background(viewModel.isFormValid ? Color.redTheme : Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .disabled(!viewModel.isFormValid)
                    
                }
            }
            .padding(12)
            
        }
        .padding()
        .onAppear {
            viewModel.onSaveSuccess = {
                isPresented = false
                Task { await vehicleViewModel.loadVehicles() }
            }
        }
    }

}


