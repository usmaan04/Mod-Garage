//
//  AddFuelLogView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 17/01/2026.
//

import SwiftUI
import PhotosUI

struct AddFuelLogView:View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddFuelLogViewModel()
    
    @EnvironmentObject var detailViewModel: VehicleDetailViewModel
    
    let vehicleId: String
    
    var body: some View {
        VStack(spacing: 24){
            ScrollView{
                VStack(spacing: 12){
                    Text("COST")
                        .font(.system(size: 12).weight(.medium))
                        .foregroundStyle(Color.navText)
                        .tracking(-0.6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField(
                        "",
                        value: $viewModel.cost,
                        format: .currency(code: "GBP")
                            .precision(.fractionLength(2)),
                        prompt: Text("140.58")
                            .foregroundStyle(Color("bodyText"))
                    )
                    .font(.system(size: 14))
                    .foregroundStyle(Color("lightBlack"))
                    .keyboardType(.decimalPad)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.rectBorder, lineWidth: 3)
                            .fill(Color.boxbackground)
                    )
                    Text("LITRES")
                        .font(.system(size: 12).weight(.medium))
                        .foregroundStyle(Color.navText)
                        .tracking(-0.6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack{
                        TextField(
                            "",
                            value: $viewModel.litres,
                            format: .number
                                .precision(.fractionLength(2)),
                            prompt: Text("140.58").foregroundStyle(Color("bodyText"))
                        )
                        .keyboardType(.decimalPad)
                        Text("L")
                    }
                    
                    .font(.system(size: 14))
                    .foregroundStyle(Color("lightBlack"))
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.rectBorder, lineWidth: 3)
                            .fill(Color.boxbackground)
                    )
                    
                    Text("ODOMETER MILEAGE")
                        .font(.system(size: 12).weight(.medium))
                        .foregroundStyle(Color.navText)
                        .tracking(-0.6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack{
                        TextField(
                            "",
                            value: $viewModel.mileage,
                            format: .number,
                            prompt: Text("53,427")
                                .foregroundStyle(Color("bodyText"))
                        )
                        .keyboardType(.decimalPad)
                        Text("MILES")
                    }
                    .font(.system(size: 14))
                    .foregroundStyle(Color("lightBlack"))
                    .textInputAutocapitalization(.never)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.rectBorder, lineWidth: 3)
                            .fill(Color.boxbackground)
                    )
                    VStack{
                        Text("PRICE PER LITRE")
                        .font(.system(size: 12).weight(.medium))
                        .foregroundStyle(Color.navText)
                        
                        HStack(spacing:0){
                            Text((String(describing: viewModel.pricePerLitre)))
                                .font(.system(size: 30).weight(.medium))
                            Text("p")
                                .font(.system(size: 14).weight(.medium))
                                .frame(maxHeight:.infinity, alignment: .bottomLeading)
                        }
                    }
                    .foregroundStyle(Color.redTheme)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.rectBorder, lineWidth: 3)
                            .fill(Color.boxbackground)
                    )
                    
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
                
                VStack{
                    Button(action: {
                        Task{
                            await viewModel.confirmFuelLog()
                        }
                    }) {
                        Text("Save")
                            .font(.system(size: 14).weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.redTheme)
                            .foregroundColor(.white)
                            .cornerRadius(100)
                    }
                }
                .padding(.top, 24)
            }
            .frame(maxHeight: .infinity)
        }
        .padding(.horizontal,17)
        .padding(.top,17)
        .frame(maxHeight: .infinity, alignment: .top)
        .navigationTitle("Add a Fuel Log")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.light, for: .navigationBar)
        .background(Color.background)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading){
                Button(role: .close) {
                    dismiss()
                }
            }
        }
        .onAppear {
            
            // Important: link AddModificationViewModel → VehicleDetailViewModel
            viewModel.onFuelLogReady = { fuelLog in
                Task {
                    await detailViewModel.addFuelLog(fuelLog, vehicleId: vehicleId)
                    dismiss()
                }
            }
        }
    }
}



#Preview{
    //AddModificationView()
}

