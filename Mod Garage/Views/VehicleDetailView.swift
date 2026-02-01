//
//  VehicleDetailView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 06/01/2026.
//

import SwiftUI
import PhotosUI

struct VehicleDetailView: View {
    
    @StateObject private var viewModel = VehicleDetailViewModel()
    
    let vehicle:VehicleModel
    
    var body: some View {
        ZStack(alignment: .top) {
            Image("AdaptiveLaunch")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            ScrollView(.vertical) {
                VStack(spacing: 30) {
                    
                    HStack {
                        Text("\(vehicle.make) " + "\(vehicle.model) ")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.lightBlack)
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack{
                        VStack(spacing: 10) {
                    
                            HStack(spacing: 10){
                                Image(systemName: "drop.halffull")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.redTheme)
                                Text("Fuel Type")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.redTheme)
                                   
                                 
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(vehicle.fuelType)
                                .font(.system(size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 22)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.rectBorder, lineWidth: 1)
                        )
                        
                        VStack(spacing: 10) {
                    
                            HStack(spacing: 10){
                                Image(systemName: "paintbrush")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.redTheme)
                                Text("Colour")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.redTheme)
                                   
                                 
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(vehicle.colour)
                                .font(.system(size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 22)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.rectBorder, lineWidth: 1)
                        )
                        
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Add modification and Fuel Log buttons
                    HStack {
                        Button {
                            viewModel.isShowingAddModification = true
                        } label: {
                            Text("Add Modification")
                                .font(.system(size: 14).weight(.bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.redTheme)
                                .foregroundColor(.white)
                                .cornerRadius(100)
                        }

                        Button {
                            viewModel.isShowingAddFuelLog = true
                        } label: {
                            Text("Add Fuel Log")
                                .font(.system(size: 14).weight(.bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.redTheme)
                                .foregroundColor(.white)
                                .cornerRadius(100)
                        }
                    }
                }
            }
            .padding(.horizontal, 17)
            .padding(.top, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationTitle("Vehicle Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // action
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $viewModel.isShowingAddModification) {
            NavigationStack {
                AddModificationView(vehicleId: vehicle.id)
                    .environmentObject(viewModel)
            }
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.isShowingAddFuelLog) {
            NavigationStack {
                AddFuelLogView(
                    vehicleId: vehicle.id,
                    previousMileage: viewModel.latestFuelLogMileage)
                    .environmentObject(viewModel)
            }
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            Task { await viewModel.loadModifications(vehicle.id)
                await viewModel.loadFuelLogs(vehicle.id)
            }
        }
    }
}

#Preview {
    VehicleDetailView(
        vehicle: VehicleModel(
            id: "veh_001",
            userId: "user_123",
            registration: "AB12 CDE",
            make: "Mercedes",
            model: "A-Class AMG",
            year: 2020,
            colour: "Blue",
            fuelType: "Petrol",
            motExpiryDate: nil,
            motStatus: nil,
            taxExpiryDate: nil,
            taxStatus: nil,
            imageURL: nil,
            isPrimary: true,
            createdAt: Date()
        )
    )
}
