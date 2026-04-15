//
//  AddVehicleView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 15/11/2025.
//

import Foundation
import SwiftUI
import PhotosUI

struct AddVehicleView: View {
    @Binding var isPresented: Bool
    @StateObject private var viewModel = AddVehicleViewModel()
    @EnvironmentObject var vehicleViewModel: VehicleViewModel

    var body: some View {
        VStack(spacing: 12) {
            // Loading spinner
            if viewModel.isLoading {
                ProgressView("Searching DVLA...")
                    .padding(.top, 20)
                    .font(.system(size: 17))

            // Show vehicle preview only if dvlaVehicle 
            } else if  viewModel.dvlaVehicle != nil && !viewModel.hasConfirmedDVLA {
                let vehicle = viewModel.dvlaVehicle
                VStack(spacing: 14) {
                    
                    Text("Is this your vehicle?")
                        .font(.system(size: 17).weight(.bold))
                        .fontWidth(.condensed)
                    
                    Text("\(vehicle!.registrationNumber)")
                        .font(.system(size: 14).weight(.bold))
                        .padding(.vertical,12)
                        .padding(.horizontal, 30)
                        .foregroundStyle(Color.black)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 1)
                                .fill(Color.yellow)
                        )
                        .frame(maxWidth: .infinity)
                    
                    
                    
                    Text("\(vehicle!.make.sentenceCased)")
                        .font(.system(size: 18))
                        .fontWidth(.condensed)
                        .frame(maxWidth: .infinity)
                    
                    
                    HStack{
                        HStack{
                            Image(systemName: "paintbrush")
                                .font(.system(size: 22))
                            Text("\(vehicle!.colour.sentenceCased)")
                                .font(.system(size: 18))
                                .fontWidth(.condensed)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        HStack{
                            Image(systemName: "calendar")
                                .font(.system(size: 22))
                            Text("\(vehicle!.yearOfManufacture.map(String.init) ?? "-")")
                                .font(.system(size: 18))
                                .fontWidth(.condensed)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                    }
                    .padding(4)
                    .frame(maxWidth: .infinity)
                    
                    HStack{
                        Button("No") {
                            viewModel.dvlaVehicle = nil
                        }
                        .font(.system(size: 12).weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .foregroundColor(.redTheme)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 12,
                                style: .continuous
                            )
                            .stroke(Color.containerBorder)
                        )
                        
                        Button(action: {
                            viewModel.hasConfirmedDVLA = true
                        }) {
                            Text("Yes")
                                .font(.system(size: 12).weight(.bold))
                                .frame(maxWidth: .infinity)
                                .padding(14)
                                .foregroundColor(.white)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.redTheme)
                        )
                    }
                }
            }else if viewModel.hasConfirmedDVLA{
                VStack(spacing: 14) {
                    Text("Enter your vehicle's model & image")
                        .font(.system(size: 17).weight(.bold))
                        .fontWidth(.condensed)
                    
                    HStack{
                        TextField(
                            "",
                            text: $viewModel.model,
                            prompt: Text("Golf")
                                .foregroundStyle(.black.opacity(0.3))
                        )
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.containerText)
                        .multilineTextAlignment(.center)
                        .keyboardType(.asciiCapable)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.containerBorder)
                                
                        )
                        HStack(spacing: 16){
                            PhotosPicker("Upload image", selection: $viewModel.carImageItem, matching: .images)
                                .font(.system(size: 10))
                                .foregroundStyle(Color.containerText)
                                .onChange(of: viewModel.carImageItem) { _ in
                                        Task {
                                            await viewModel.loadImage()
                                        }
                                    }
                            if let selectedImage = viewModel.carImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.containerBorder)
                                
                        )
                    }
                    
                    if !vehicleViewModel.vehicles.isEmpty {
                        Toggle(isOn: $viewModel.makePrimary) {
                            Text("Make this primary?")
                                .font(.system(size: 12))
                                .foregroundColor(Color.containerText)
                        }
                        .tint(Color.redTheme)
                        
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    HStack{
                        Button("Back") {
                            viewModel.hasConfirmedDVLA = false
                        }
                        .font(.system(size: 12).weight(.bold))
                        .fontWidth(.condensed)
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .foregroundColor(.redTheme)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 12,
                                style: .continuous
                            )
                            .stroke(Color.containerBorder)
                        )
                        
                        Button(action: {
                            Task { await viewModel.confirmVehicle() }
                        }) {
                            Text("Add Vehicle")
                                .font(.system(size: 12).weight(.bold))
                                .fontWidth(.condensed)
                                .frame(maxWidth: .infinity)
                                .padding(14)
                                .foregroundColor(.white)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.redTheme)
                        )
                    }
                }
                .padding(12)
                
            // Show Add Vehicle Form
            } else {
                VStack(spacing: 24){
                    Text("Add Vehicle")
                        .font(.system(size: 20).weight(.bold))
                        .fontWidth(.condensed)
                        .padding(.bottom,6)

                    TextField(
                        "",
                        text: $viewModel.registration,
                        prompt: Text("ENTER REG")
                            .foregroundStyle(.black.opacity(0.3))
                    )
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.black)
                    .multilineTextAlignment(.center)
                    .autocorrectionDisabled(true)
                    .keyboardType(.asciiCapable)
                    .autocapitalization(.allCharacters)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black, lineWidth: 5)
                            .fill(Color.yellow)
                    )
                    
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
                    
                        Button(action: {
                            viewModel.searchRegistration()
                        }) {
                            Text("Search")
                                .font(.system(size: 12).weight(.bold))
                                .fontWidth(.condensed)
                                .frame(maxWidth: .infinity)
                                .padding(14)
                                .foregroundColor(.white)
                        }
                        .background(viewModel.registration.isEmpty ? Color.gray : Color.redTheme)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .disabled(viewModel.registration.isEmpty)
                        
                    }
                }
                .padding(12)
            }
        }
        .onAppear {
            viewModel.existingVehicleCount = vehicleViewModel.vehicles.count
            
            // Important: link AddVehicleViewModel → VehicleViewModel
            viewModel.onVehicleReady = { vehicle in
                Task {
                    await vehicleViewModel.addVehicle(vehicle)
                    isPresented = false
                }
            }
        }
        .padding()
    }
}

// Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var isPresented = true
        @StateObject private var vehicleVM = VehicleViewModel()

        var body: some View {
            AddVehicleView(isPresented: $isPresented)
                .environmentObject(vehicleVM)
        }
    }

    return PreviewWrapper()
}
