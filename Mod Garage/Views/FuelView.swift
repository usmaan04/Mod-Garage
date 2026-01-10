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
                VStack(){
                    
                    if let vehicle = viewModel.primaryVehicle{
                        ScrollView(.vertical) {
                            VStack(spacing: 30) {
                                Image("AdaptiveLaunch")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 140, height: 140)
                                
                                NavigationLink(destination: VehicleDetailView(vehicle: vehicle)){                                HStack(){
                                        VStack(alignment: .leading){
                                            Text(vehicle.make)
                                                .font(.system(size: 12))
                                                .foregroundStyle(Color.bodyText)
                                            Text(vehicle.model)
                                                .font(.system(size: 16).weight(.semibold))
                                                .foregroundStyle(Color.black)
                                        }
                                        
                                        HStack{
                                            Text("\(vehicle.registration)")
                                                .font(.system(size: 15).weight(.bold))
                                                .padding(.vertical,6)
                                                .padding(.horizontal,20)
                                                .foregroundStyle(Color.black)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 1)
                                                       
                                                        .fill(Color.yellow)
                                                )
                                            Image(systemName: "chevron.right")
                                            foregroundStyle(Color.redTheme)
                                        }
                                        .frame(maxWidth: .infinity,alignment: .trailing)
                                        
                                    }
                                    .padding(20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.rectFill)
                                    )
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
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
            .background(Color.redTheme)
            .navigationTitle("Fuel Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear { Task {await viewModel.loadVehicleData()} }
        }
        
    }
}

#Preview {
    FuelView()
}
