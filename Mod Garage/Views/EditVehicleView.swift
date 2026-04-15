//
//  AddVehicleView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 15/11/2025.
//

import Foundation
import SwiftUI

struct EditVehicleView: View {
    
    // Arguments and view models
    let vehicle: VehicleModel

    @Binding var isPresented: Bool
    @StateObject var viewModel: EditVehicleViewModel
    @EnvironmentObject var vehicleViewModel: VehicleViewModel

    // Initialiser to set the passed vehicle
    init(vehicle: VehicleModel, isPresented: Binding<Bool>) {
        self.vehicle = vehicle
        self._isPresented = isPresented
        _viewModel = StateObject(wrappedValue: EditVehicleViewModel(vehicle: vehicle))
    }

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 24){
                // Title
                Text("Edit Vehicle")
                    .font(.system(size: 17).weight(.bold))
                    .fontWidth(.condensed)
                    .padding(.bottom,6)
                
                HStack{
                    
                    // Model label and field
                    VStack(spacing: 8){
                        Text("Model")
                            .font(.system(size: 14).weight(.medium))
                        TextField(
                            "",
                            text: $viewModel.model,
                            prompt: Text("Enter Model")
                                .foregroundStyle(Color.containerText)
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
                    
                    // Colour label and field
                    VStack(spacing: 8){
                        Text("Colour")
                            .font(.system(size: 14).weight(.medium))
                        TextField(
                            "",
                            text: $viewModel.colour,
                            prompt: Text("Enter Colour")
                                .foregroundStyle(Color.containerText)
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
                
                // Error message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 8)
                        .multilineTextAlignment(.center)
                }
                
                HStack{
                    
                    // Cancel button
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .font(.system(size: 12).weight(.bold))
                            .fontWidth(.condensed)
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
                
                    // Save button
                    Button(action: {
                        viewModel.saveChanges()
                    }) {
                        Text("Save")
                            .font(.system(size: 12).weight(.bold))
                            .fontWidth(.condensed)
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


