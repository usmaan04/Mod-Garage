//
//  VehicleDetailView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 06/01/2026.
//

import SwiftUI
import PhotosUI

private func currencyString(from value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "GBP"
    return formatter.string(from: NSNumber(value: value)) ?? "£0.00"
}

struct VehicleDetailView: View {
    
    @StateObject private var viewModel = VehicleDetailViewModel()
    @EnvironmentObject var homeViewModel: HomeViewModel
    @Namespace private var timeframeNamespace
    
    let vehicle:VehicleModel
    
    
    private var timeframePills: some View {
        HStack(spacing: 10) {
            ForEach(ListOption.allCases) { option in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0.2)) {
                        viewModel.listOption = option
                    }
                } label: {
                    ZStack {
                        if viewModel.listOption == option {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.backgroundW)
                                .matchedGeometryEffect(id: "timeframeHighlight", in: timeframeNamespace)
                        }
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.clear)
                        HStack(spacing: 8){
                            if option == .mods{
                                Image(systemName: "wrench.and.screwdriver.fill")
                                    .foregroundStyle(
                                        viewModel.listOption == option ? Color.redTheme : Color.navText
                                    )
                            }
                            else{
                                Image(systemName: "fuelpump.fill")
                                    .foregroundStyle(
                                        viewModel.listOption == option ? Color.redTheme : Color.navText
                                    )
                            }
                            Text(option.label)
                                .foregroundStyle(
                                    viewModel.listOption == option ? Color.lightBlack : Color.navText
                                )
                                .padding(.vertical, 12)
                                
                        }
                        .font(.system(size: 12, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.rectBorder)
        )
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ZStack(alignment: .top) {
                Image("carimg")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea(.container, edges: .top)
                
            }
            GeometryReader{proxy in
                VStack{
                    ScrollView(.vertical) {
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 6) {
                                if vehicle.isPrimary{
                                    Text("PRIMARY")
                                        .font(.system(size: 12).weight(.medium))
                                        .foregroundStyle(Color.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.redTheme)
                                        )
                                }
                                Text("\(vehicle.make) " + "\(vehicle.model) ")
                                    .font(.system(size: 34).weight(.bold))
                                    .foregroundStyle(Color.lightBlack)
                            }
                            
                            VStack{
                                HStack{
                                    VStack(spacing: 10) {
                                
                                        HStack(spacing: 10){
                                            Image(systemName: "drop.fill")
                                                .font(.system(size: 14))
                                                .foregroundStyle(Color.redTheme)
                                            Text("Fuel Type")
                                                .font(.system(size: 12).weight(.medium))
                                                .foregroundStyle(Color.redTheme)
                                               
                                             
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text(vehicle.fuelType)
                                            .font(.system(size: 18).weight(.semibold))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.rectBorder, lineWidth: 1)
                                            .fill(Color.boxbackground)
                                            .shadow(color: Color.black.opacity(0.08),radius: 4, x: 0, y: 5)
                                    )
                                    
                                    VStack(spacing: 10) {
                                
                                        HStack(spacing: 10){
                                            Image(systemName: "paintbrush.fill")
                                                .font(.system(size: 14))
                                                .foregroundStyle(Color.redTheme)
                                            Text("Colour")
                                                .font(.system(size: 12).weight(.medium))
                                                .foregroundStyle(Color.redTheme)
                                               
                                             
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text(vehicle.colour)
                                            .font(.system(size: 18).weight(.semibold))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.rectBorder, lineWidth: 1)
                                            .fill(Color.boxbackground)
                                            .shadow(color: Color.black.opacity(0.08),radius: 4, x: 0, y: 5)
                                    )
                                    
                                    
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack{
                                    VStack(spacing: 10) {
                                
                                        HStack(spacing: 10){
                                            Image(systemName: "gauge.with.needle.fill")
                                                .font(.system(size: 14))
                                                .foregroundStyle(Color.redTheme)
                                            Text("Mileage")
                                                .font(.system(size: 12).weight(.medium))
                                                .foregroundStyle(Color.redTheme)
                                               
                                             
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        if let mileage = viewModel.latestFuelLogMileage {
                                            Text("\(Int(mileage)) mi")
                                                .font(.system(size: 18).weight(.semibold))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        } else {
                                            Text("-")
                                                .font(.system(size: 18).weight(.semibold))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.rectBorder, lineWidth: 1)
                                            .fill(Color.boxbackground)
                                            .shadow(color: Color.black.opacity(0.08),radius: 4, x: 0, y: 5)
                                    )
                                    
                                    VStack(spacing: 10) {
                                
                                        HStack(spacing: 10){
                                            Image(systemName: "calendar.circle.fill")
                                                .font(.system(size: 14))
                                                .foregroundStyle(Color.redTheme)
                                            Text("Year")
                                                .font(.system(size: 12).weight(.medium))
                                                .foregroundStyle(Color.redTheme)
                                               
                                             
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text("\(vehicle.year)")
                                            .font(.system(size: 18).weight(.semibold))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.rectBorder, lineWidth: 1)
                                            .fill(Color.boxbackground)
                                            .shadow(color: Color.black.opacity(0.08),radius: 4, x: 0, y: 5)
                                    )
                                    
                                    
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            timeframePills
                            
                            if viewModel.listOption == .mods{
                                Text("Installed Mods")
                                    .foregroundColor(.lightBlack)
                                    .font(.system(size: 16).weight(.semibold))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                ForEach(viewModel.modifications.sorted { $0.createdAt > $1.createdAt
                                }
                                ) { modification in
                                    ModificationCard(
                                        modification: modification,
                                    )
                                    .environmentObject(homeViewModel)
                                    
                                }
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
                            }
                            else{
                                Text("Fill Ups")
                                    .foregroundColor(.lightBlack)
                                    .font(.system(size: 16).weight(.semibold))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                ForEach(viewModel.fuelLogs.sorted { $0.createdAt > $1.createdAt
                                }
                                ) { fuelLog in
                                    FuelLogCard(
                                        fuelLog: fuelLog,
                                    )
                                    .environmentObject(homeViewModel)
                                    
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
                        .padding(.horizontal, 17)
                        .padding(.top, 80)
                        .padding(.bottom, 16)
                    }
                    .frame(maxHeight: proxy.size.height - 48)
                 
                }
                .background(LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.background.opacity(0.0), location: 0.0),
                        .init(color: Color.background.opacity(0.2), location: 0.1),
                       
                        .init(color: Color.background.opacity(1), location: 0.24)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.backgroundW)
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
                    method: "details",
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

struct ModificationCard: View {
    @EnvironmentObject var viewModel: HomeViewModel

    let modification: ModificationModel

    var body: some View {
        HStack(spacing: 18){
            ZStack{
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.rectFill)
                    .frame(width:70, height: 60)
                
                switch modification.type {
                case "Exhaust":
                    Image(systemName: "pipe.and.drop.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color.redTheme)
                case "Windows":
                    Image(systemName: "car.window.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color.redTheme)
                case "Lights":
                    Image(systemName: "lightbulb.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color.redTheme)
                case "Engine":
                    Image(systemName: "engine.combustion.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color.redTheme)
                case "Bodykit":
                    Image(systemName: "car.side.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color.redTheme)
                default:
                    Image(systemName: "car.side.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.redTheme)
                }
            }
            VStack(alignment: .leading, spacing: 4){
                Text(modification.name)
                    .font(.system(size: 16).weight(.bold))
                    .foregroundStyle(Color.lightBlack)
                    .multilineTextAlignment(.leading)
                
                Text("Installed " + "\(viewModel.modDateFormatter(modification.date))")
                    .font(.system(size: 12).weight(.medium))
                    .foregroundStyle(Color.navText)
                   
                
                Text(modification.type)
                    .font(.system(size: 10).weight(.semibold))
                    .foregroundStyle(Color.navText)
                    .padding(.horizontal,8)
                    .padding(.vertical,6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.rectBorder.opacity(0.4))
                    )
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .frame(maxWidth:. infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.boxbackground)
        )
    }
}

#Preview {
    VehicleDetailView(
        vehicle: VehicleModel(
            id: "veh_001",
            userId: "user_123",
            registration: "AB12 CDE",
            make: "Porsche",
            model: "911 GT3",
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
