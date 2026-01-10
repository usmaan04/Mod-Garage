//
//  VehicleDetailView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 06/01/2026.
//

import SwiftUI

struct VehicleDetailView: View {
    
    let vehicle:VehicleModel
    
    var body: some View {
        VStack {
            ZStack(alignment: .top){
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
                        
                        HStack(){
                            VStack(alignment: .leading){
                                Text(vehicle.make)
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.bodyText)
                                Text(vehicle.model)
                                    .font(.system(size: 16).weight(.semibold))
                            }
                            
                            
                            Text("\(vehicle.registration)")
                                .font(.system(size: 15).weight(.bold))
                                .padding(.vertical,6)
                                .padding(.horizontal,20)
                                .foregroundStyle(Color.black)
                                .background(
                                    RoundedRectangle(cornerRadius: 1)
                                       
                                        .fill(Color.yellow)
                                )
                                .frame(maxWidth: .infinity,alignment: .trailing)
                            
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading, spacing: 14){
                            HStack(spacing: 10){
                                Image(systemName: "drop.halffull")
                                Text("Fuel Type")
                                    .font(.system(size: 14))
                                Text(vehicle.fuelType)
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.navText)
                                    .frame(maxWidth:.infinity, alignment: .trailing)
                            }
                            Divider()
                            HStack(spacing: 10){
                                Image(systemName: "paintbrush")
                                Text("Colour")
                                    .font(.system(size: 14))
                                Text(vehicle.colour)
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.navText)
                                    .frame(maxWidth:.infinity, alignment: .trailing)
                            }
                            Divider()
                            HStack(spacing: 10){
                                Image(systemName: "calendar")
                                Text("Year")
                                    .font(.system(size: 14))
                                Text("\(vehicle.year)")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.navText)
                                    .frame(maxWidth:.infinity, alignment: .trailing)
                                    
                            }
                        }
                        .padding(20)
                        .background(
                            Rectangle()
                                .fill(Color.rectFill)
                                .frame(width: .infinity)
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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
