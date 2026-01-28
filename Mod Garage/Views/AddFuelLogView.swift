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
                    Text("Cost")
                        .font(.system(size: 14).weight(.medium))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField(
                        "",
                        value: $viewModel.cost,
                        format: .currency(code: "GBP"),
                        prompt: Text("140.58")
                            .foregroundStyle(Color("bodyText"))
                    )
                    .font(.system(size: 13))
                    .foregroundStyle(Color("lightBlack"))
                    .keyboardType(.decimalPad)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.vertical, 16)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.rectBorder, lineWidth: 1)
                    )
                    Text("Litres")
                        .font(.system(size: 14).weight(.medium))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField(
                        "",
                        value: $viewModel.litres,
                        format: .currency(code: "GBP"),
                        prompt: Text("140.58")
                            .foregroundStyle(Color("bodyText"))
                    )
                    .font(.system(size: 13))
                    .foregroundStyle(Color("lightBlack"))
                    .keyboardType(.decimalPad)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.vertical, 16)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.rectBorder, lineWidth: 1)
                    )
                    Text("Price per Litre")
                        .font(.system(size: 14).weight(.medium))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(String(describing: viewModel.pricePerLitre))
                        .font(.system(size: 12).weight(.medium))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Mileage")
                        .font(.system(size: 14).weight(.medium))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField(
                        "",
                        value: $viewModel.mileage,
                        format: .number,
                        prompt: Text("140.58")
                            .foregroundStyle(Color("bodyText"))
                    )
                    .font(.system(size: 13))
                    .foregroundStyle(Color("lightBlack"))
                    .keyboardType(.decimalPad)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.vertical, 16)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.rectBorder, lineWidth: 1)
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

