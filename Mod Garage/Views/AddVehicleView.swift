//
//  AddVehicleView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 15/11/2025.
//

import Foundation
import SwiftUI

struct AddVehicleView: View {
    @StateObject private var viewModel = AddVehicleViewModel()

    var body: some View {
        VStack(spacing: 12) {
            Text("Add Vehicle")
                .font(.system(size: 16).weight(.semibold))
                .foregroundStyle(Color.lightBlack)
            TextField(
                    "",
                    text: $viewModel.registration,
                    prompt: Text("Enter your registration here...")
                        .foregroundColor(Color("bodyText"))
                )
                .font(.system(size: 12))
                .autocorrectionDisabled()
                .autocapitalization(.allCharacters)
                .padding(.vertical, 16)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.rectBorder, lineWidth: 1)
                )
            Button(action: {
                viewModel.searchRegistration()
            }) {
                Text("Search Registration")
                    .font(.system(size: 14).weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
            }
            .background(viewModel.registration.isEmpty ? Color.gray : Color.redTheme)
            .clipShape(RoundedRectangle(cornerRadius: 50, style: .continuous))
            .padding(.vertical, 12)
            .disabled(viewModel.registration.isEmpty)
            
            // After the Search button
            Group {

                //  Loading State
                if viewModel.isLoading {
                    ProgressView("Searching DVLA...")
                        .padding(.top, 10)
                }

                // Error Message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 8)
                }

                // Vehicle Detail Preview
                if let vehicle = viewModel.dvlaVehicle {
                    VStack(alignment: .leading, spacing: 10) {

                        Text("Is this your vehicle?")
                            .font(.headline)

                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.lightBlack.opacity(0.3), lineWidth: 1)
                            .background(Color.gray.opacity(0.08))
                            .overlay(
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Registration: \(vehicle.registrationNumber ?? "-")")
                                    Text("Make: \(vehicle.make ?? "-")")
                                    Text("Colour: \(vehicle.colour ?? "-")")
                                    Text("Year: \(vehicle.yearOfManufacture.map(String.init) ?? "-")")
                                }
                                .padding()
                            )
                            .frame(maxWidth: .infinity)

                        // Confirm Button
                        Button(action: {
                            viewModel.confirmVehicle()
                        }) {
                            Text("Confirm Vehicle")
                                .font(.system(size: 14).weight(.bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.redTheme)
                                .foregroundColor(.white)
                                .cornerRadius(50)
                        }
                        .padding(.top, 10)

                        // Cancel Button
                        Button("Cancel") {
                            viewModel.dvlaVehicle = nil
                        }
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                    }
                    .padding(.top, 15)
                }
            }
        }
        .padding()
    }
}

// Preview
#Preview {
    AddVehicleView()
}


