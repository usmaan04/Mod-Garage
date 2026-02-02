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
    let previousMileage: Int?
    
    var body: some View {
        VStack(spacing: 24){
            ScrollView{
                VStack(spacing: 12){
                    Text("LOCATION")
                        .font(.system(size: 12).weight(.medium))
                        .foregroundStyle(Color.navText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField(
                        "e.g. Shell, High Street",
                        text: $viewModel.location
                    )
                    .font(.system(size: 14))
                    .foregroundStyle(Color("lightBlack"))
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled(false)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.rectBorder, lineWidth: 3)
                            .fill(Color.boxbackground)
                    )
                    HStack{
                        Text("TOTAL COST")
                            .font(.system(size: 12).weight(.medium))
                            .foregroundStyle(Color.navText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("LITRES")
                            .font(.system(size: 12).weight(.medium))
                            .foregroundStyle(Color.navText)
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
                                .stroke(Color.rectBorder, lineWidth: 3)
                                .fill(Color.boxbackground)
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
                        }
                        .padding(16)
                        .keyboardType(.decimalPad)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.rectBorder, lineWidth: 3)
                                .fill(Color.boxbackground)
                        )
                    }
                    .font(.system(size: 14))
                    .foregroundStyle(Color("lightBlack"))
                    HStack{
                        Text("ODOMETER MILEAGE")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("RE-FUEL DATE")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .font(.system(size: 12).weight(.medium))
                    .foregroundStyle(Color.navText)
                    
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
                        
                        Button {
                            viewModel.showDatePicker.toggle()
                        } label: {
                            HStack(spacing: 26){
                                Text(viewModel.date.formatted(date: .abbreviated, time: .omitted))
                                Image(systemName: "calendar")
                            }
                            .font(.system(size: 14))
                            .foregroundStyle(Color.lightBlack)
                            .padding(16)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.rectBorder, lineWidth: 3)
                                    .fill(Color.boxbackground)
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
            viewModel.previousMileage = previousMileage
                    
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

