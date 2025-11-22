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
    @State private var vehicleToDelete:VehicleModel? = nil
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        GeometryReader { proxy in
            let maxScrollHeight = proxy.size.height - 84
            let maxCardWidth = proxy.size.width
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
                    // Search and filters
                    HStack{
                        
                    }
                    //Card Scroll display
                
                    VStack{
                        if viewModel.isLoading{
                            VStack{
                                ProgressView("Finding vehicles...")
                                    .padding(.top, 20)
                                    .font(.system(size: 14))
                            }
                            .frame(maxWidth: .infinity, minHeight: maxScrollHeight - 94, alignment: .center)
                        }else if viewModel.vehicles.isEmpty{
                            VStack{
                                Image(systemName: "car.rear.hazardsign")
                                    .foregroundStyle(Color.redTheme)
                                    .font(.system(size: 50))
                                    .foregroundStyle(Color.black)
                                Text("Uh, oh it seems you haven't added any vehicles yet.")
                                    .foregroundStyle(.bodyText)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, minHeight: maxScrollHeight - 94, alignment: .center)
                        }else{
                            List {
                                ForEach(viewModel.vehicles) { vehicle in
                                    VehicleCard(
                                        vehicle: vehicle,
                                        maxCardWidth: maxCardWidth,
                                        vehicleToDelete: $vehicleToDelete,
                                        showDeleteConfirmation: $showDeleteConfirmation
                                    )
                                    .environmentObject(viewModel)
                                    .padding(.vertical, 10)
                                    .listRowInsets(.init())
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                }
                            }
                            .listStyle(.plain)
                            
                        }
                    }
                    .frame(maxHeight: maxScrollHeight)
                    .alert("Delete Vehicle?", isPresented: $showDeleteConfirmation) {
                        Button("Delete", role: .destructive) { Task {
                            if let vehicle = vehicleToDelete {
                                await viewModel.deleteVehicle(vehicle)
                            }
                        }}
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("Are you sure you want to delete this vehicle?")
                    }
                    
                }
                .padding(.horizontal, 17)
                .padding(.top, 14)
                .frame(maxWidth: .infinity, maxHeight: maxScrollHeight + 14 ,alignment: .top)
                
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
            .onAppear{
                Task{
                    await viewModel.loadVehicles()
                }
            }
        }
    }
}

struct VehicleCard: View {
    @EnvironmentObject var viewModel: VehicleViewModel
    let vehicle: VehicleModel
    let maxCardWidth: CGFloat
    @Binding var vehicleToDelete: VehicleModel?
    @Binding var showDeleteConfirmation: Bool
    var action: (() -> Void)? = nil
    
    
    
    var body: some View {
        Button(action: {
           print("Pressed")
        }) {
            HStack(spacing: 0){
                VStack(alignment: .leading, spacing: 12){
                    Text("\(vehicle.registration)")
                        .font(.system(size: 10).weight(.bold))
                        .padding(.vertical,6)
                        .padding(.horizontal,20)
                        .foregroundStyle(Color.black)
                        .background(
                            RoundedRectangle(cornerRadius: 1)
                                .stroke(Color.black, lineWidth: 1)
                                .fill(Color.yellow)
                        )
                        
                    Text("\(vehicle.make) " + "\(vehicle.model) ")
                        .font(.system(size: 14).weight(.bold))
                        .foregroundStyle(Color.lightBlack)
                    Divider()
                        .frame(maxWidth: .infinity, maxHeight: 1)
                        .background(Color.rectBorder)
                        .frame(maxWidth: .infinity)
                    HStack(spacing: 15){
                        Image(systemName: "drop.halffull")
                        Text("\(vehicle.fuelType)")
                        Divider()
                            .background(Color.rectBorder)
                            .frame(maxWidth: 1, maxHeight: .infinity)
                        Image(systemName: "paintbrush")
                        Text("\(vehicle.colour)")
                    }
                    .font(.system(size: 14))
                    .foregroundStyle(Color.navText)
                    .frame(maxWidth: .infinity, maxHeight: 12, alignment: .leading)
                }
                .frame(maxWidth: maxCardWidth - 41)
                VStack{
                    if vehicle.isPrimary == true{
                        Text("Primary")
                            .font(.system(size: 12).weight(.bold))
                            .foregroundStyle(Color.white)
                            .padding(.vertical,4)
                            .padding(.horizontal,8)
                            .background(
                                Capsule()
                                    .fill(Color.redTheme)
                            )
                            .frame(maxHeight: .infinity, alignment: .top)
                            .offset(y: -10)
                    }
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.redTheme)
                        .frame(maxHeight: .infinity, alignment: .center)
                }
                .frame(maxWidth: maxCardWidth - 41, alignment: .trailing)
            }
            .padding(.horizontal,12)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.rectBorder, lineWidth: 1)
                    
            )
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                vehicleToDelete = vehicle
                showDeleteConfirmation = true
            } label: {
                Image(systemName: "trash")
                Text("Delete")
            }
            Button {
                Task { await viewModel.makePrimary(vehicle) }
            } label: {
                Image(systemName: vehicle.isPrimary ? "star.fill" : "star")
                Text(vehicle.isPrimary ? "Primary" : "Make Primary")
            }
            .tint(vehicle.isPrimary ? .gray : .yellow)
            .disabled(vehicle.isPrimary)
        }
    }
}

// Preview
#Preview {
    VehicleView()
}

