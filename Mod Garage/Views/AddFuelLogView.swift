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
    @EnvironmentObject var fuelViewModel: FuelViewModel
    
    let vehicleId: String
    let method: String
    let previousMileage: Int?
    
    var body: some View {
        VStack(spacing: 24){
            ScrollView{
                VStack(spacing: 12){
                    Text("Location")
                        .font(.system(size: 16).weight(.medium))
                        .fontWidth(.condensed)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField(
                        "e.g. Shell, High Street",
                        text: $viewModel.location
                    )
                    .font(.system(size: 14))
                    .foregroundStyle(Color.containerText)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled(false)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.containerBorder, lineWidth: 3)
                            .fill(Color.container)
                    )
                    HStack{
                        Text("Total Cost")
                            .font(.system(size: 16).weight(.medium))
                            .fontWidth(.condensed)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Litres Filled")
                            .font(.system(size: 16).weight(.medium))
                            .fontWidth(.condensed)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    HStack{
                        TextField(
                            "",
                            value: $viewModel.cost,
                            format: .currency(code: "GBP")
                                .precision(.fractionLength(2)),
                            prompt: Text("140.58")
                                .foregroundStyle(Color("bodyText"))
                        )
                        .padding(16)
                        .keyboardType(.decimalPad)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.containerBorder, lineWidth: 3)
                                .fill(Color.container)
                        )
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
                                .fontWidth(.condensed)
                        }
                        .padding(16)
                        .keyboardType(.decimalPad)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.containerBorder, lineWidth: 3)
                                .fill(Color.container)
                        )
                    }
                    .font(.system(size: 14))
                    .foregroundStyle(Color.containerText)
                    
                    HStack{
                        Text("Odometer Mileage")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Re-Fuel Date")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .font(.system(size: 16).weight(.medium))
                    .fontWidth(.condensed)
                    
                    HStack{
                        HStack{
                            TextField(
                                "",
                                value: $viewModel.mileage,
                                format: .number,
                                prompt: Text("53,427")
                                    .foregroundStyle(Color("bodyText"))
                            )
                            .keyboardType(.decimalPad)
                            Text("Miles")
                                .font(.system(size: 14).weight(.medium))
                                .fontWidth(.condensed)
                        }
                        .font(.system(size: 14))
                        .foregroundStyle(Color.containerText)
                        .textInputAutocapitalization(.never)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.containerBorder, lineWidth: 3)
                                .fill(Color.container)
                        )
                        
                        Button {
                            viewModel.showDatePicker.toggle()
                        } label: {
                            HStack(spacing: 26){
                                Text(viewModel.date.formatted(date: .abbreviated, time: .omitted))
                                Image(systemName: "calendar")
                            }
                            .font(.system(size: 14))
                            .foregroundStyle(Color.containerText)
                            .padding(16)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.containerBorder, lineWidth: 3)
                                    .fill(Color.container)
                            )
                        }
                        .sheet(isPresented: $viewModel.showDatePicker) {
                            DatePicker(
                                "Select date",
                                selection: $viewModel.date,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .presentationDetents([.medium])
                        }
                    }

                    VStack{
                        Text("Price Per Litre")
                            .font(.system(size: 16).weight(.medium))
                            .fontWidth(.condensed)
                            .foregroundStyle(Color.containerText)
                        
                        HStack(spacing:0){
                            Text("£")
                                .font(.system(size: 30).weight(.medium))
                                .fontWidth(.condensed)
                                .frame(maxHeight:.infinity, alignment: .bottomLeading)
                            Text((String(describing: viewModel.pricePerLitre)))
                                .font(.system(size: 30).weight(.medium))
                        }
                    }
                    .foregroundStyle(Color.redTheme)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.containerBorder, lineWidth: 3)
                            .fill(Color.container)
                    )
                    
                }
                .padding(.horizontal,17)
                
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
                .padding(.horizontal,17)
                .padding(.top, 24)
            }
            .frame(maxHeight: .infinity)
        }
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
            viewModel.previousMileage = previousMileage
                    
            if method == "fuel"{
                // Important: link AddModificationViewModel → FuelViewModel
                viewModel.onFuelLogReady = { fuelLog in
                    Task {
                        await fuelViewModel.addFuelLog(fuelLog, vehicleId: vehicleId)
                        dismiss()
                    }
                }
            }else{
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
}



#Preview{
    //AddModificationView()
}

