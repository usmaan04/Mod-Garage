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
        VStack {
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.background)
                    .stroke(Color.rectBorder, lineWidth: 1)

                ScrollView(.vertical) {
                    VStack(spacing: 30) {
                        Image("AdaptiveLaunch")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 140)

                        Divider()

                        HStack {
                            VStack(alignment: .leading) {
                                Text(vehicle.make)
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.bodyText)

                                Text(vehicle.model)
                                    .font(.system(size: 16).weight(.semibold))
                            }

                            Text(vehicle.registration)
                                .font(.system(size: 15).weight(.bold))
                                .padding(.vertical, 6)
                                .padding(.horizontal, 20)
                                .foregroundStyle(Color.black)
                                .background(
                                    RoundedRectangle(cornerRadius: 1)
                                        .fill(Color.yellow)
                                )
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 10) {
                                Image(systemName: "drop.halffull")
                                Text("Fuel Type")
                                    .font(.system(size: 14))
                                Text(vehicle.fuelType)
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.navText)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            Divider()

                            HStack(spacing: 10) {
                                Image(systemName: "paintbrush")
                                Text("Colour")
                                    .font(.system(size: 14))
                                Text(vehicle.colour)
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.navText)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            Divider()

                            HStack(spacing: 10) {
                                Image(systemName: "calendar")
                                Text("Year")
                                    .font(.system(size: 14))
                                Text("\(vehicle.year)")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.navText)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .padding(20)
                        .background(
                            Rectangle()
                                .fill(Color.rectFill)
                        )
                        .frame(maxWidth: .infinity)

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
                .padding(17)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.redTheme)
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
        }
        .onAppear {
            Task { await viewModel.loadModifications(vehicle.id) }
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
