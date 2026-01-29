//
//  FuelView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 11/11/2025.
//

import Foundation
import SwiftUI

struct FuelView: View {
    @StateObject private var viewModel = FuelViewModel()
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    var body: some View {
        NavigationView{
            VStack {
                VStack{
                    if let vehicle = viewModel.primaryVehicle{
                        ScrollView(.vertical) {
                            VStack(spacing: 30) {
                                Image("AdaptiveLaunch")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 140, height: 140)
                                
                                NavigationLink(destination: VehicleDetailView(vehicle: vehicle)){                                HStack{
                                        VStack(alignment: .leading){
                                            Text(vehicle.make)
                                                .font(.system(size: 12))
                                                .foregroundStyle(Color.bodyText)
                                            Text(vehicle.model)
                                                .font(.system(size: 16).weight(.semibold))
                                                .foregroundStyle(Color.black)
                                        }
                                        
                                        HStack{
                                        }
                                        .frame(maxWidth: .infinity,alignment: .trailing)
                                        
                                    }
                                    .padding(20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.rectFill)
                                    )
                                }
                                HStack{
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.lightPink)
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: "wallet.bifold")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                            .foregroundStyle(Color.redTheme)
                                    }
                                    VStack(alignment: .leading, spacing: 4){
                                        Text("Total Spending")
                                            .font(.system(size: 10))
                                            .foregroundStyle(Color.bodyText)
                                            .tracking(-0.4)
                                        Text("£1000")
                                            .font(.system(size: 14).weight(.medium))
                                            .foregroundStyle(Color.lightBlack)

                                    }
                                    Image(systemName:"fuelpump.fill")
                                        .scaledToFill()
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .font(.system(size:22))
                                        .foregroundStyle(Color.bodyText)
                                        .opacity(0.4)
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity,alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.rectBorder, lineWidth: 1)
                                )
                            }
                        }
                        .padding(17)
                    }
                    else{
                        Text("Hey there, please add a vehicle to see your fuel details")
                    }
                
                
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(RoundedRectangle(cornerRadius: 20)
                    .fill(Color.background)
                    .stroke(Color.rectBorder, lineWidth: 1))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.background)
            .navigationTitle("Fuel Log")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task {
                    await viewModel.loadVehicleData()
                    }
            }
        }
    }
}

#Preview {
    FuelView()
}
