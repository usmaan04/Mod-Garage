//
//  AddModificationView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 12/01/2026.
//

import SwiftUI
import PhotosUI

struct AddModificationView:View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddModificationViewModel()
    
    @EnvironmentObject var detailViewModel: VehicleDetailViewModel
    
    let vehicleId: String
    
    var body: some View {
        VStack(spacing: 24){
            ScrollView{
                VStack(spacing: 12){
                    Text("Modification Type")
                        .font(.system(size: 14).weight(.medium))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ModTypeDropdown(selection: $viewModel.modType, options: viewModel.modTypes)
                    Text("Modification Name")
                        .font(.system(size: 14).weight(.medium))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField(
                        "",
                        text: $viewModel.modName,
                        prompt: Text("Sport Exhaust System")
                            .foregroundStyle(Color("bodyText"))
                    )
                    .font(.system(size: 13))
                    .keyboardType(.asciiCapable)
                    .textInputAutocapitalization(.never)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.rectBorder, lineWidth: 1)
                    )
                    Text("Cost")
                        .font(.system(size: 14).weight(.medium))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField(
                        "",
                        value: $viewModel.modCost,
                        format: .currency(code: "GBP"),
                        prompt: Text("140.58")
                            .foregroundStyle(Color("bodyText"))
                    )
                    .font(.system(size: 13))
                    .foregroundStyle(Color("lightBlack"))
                    .keyboardType(.decimalPad)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.rectBorder, lineWidth: 1)
                    )
                    Text("Description")
                        .font(.system(size: 14).weight(.medium))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ZStack(alignment: .top){
                        TextEditor(
                            text: $viewModel.modDesc)
                        
                        .font(.system(size: 13))
                        .tracking(-0.2)
                        .keyboardType(.asciiCapable)
                        
                        if viewModel.modDesc == "" {
                            Text("Enter description")
                                .tracking(-0.2)
                                .frame(maxWidth: .infinity, alignment:.leading)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 8)
                        }
                    
                    }
                    .font(.system(size: 13))
                    .foregroundStyle(Color("bodyText"))
                    .frame(height: 80, alignment: .leading)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.rectBorder, lineWidth: 1)
                    )
                    Text("Before Image")
                        .font(.system(size: 14).weight(.medium))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    VStack(spacing: 12){
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 24))
                        VStack(spacing: 4){
                            Text("Add Image")
                                .font(.system(size: 14).weight(.medium))
                            PhotosPicker("Click to upload an image (PDF, JPG, PNG)", selection: $viewModel.beforeImage)
                                .font(.system(size: 10))
                                .foregroundStyle(Color.bodyText)
                        }
                    }
                    .padding(.vertical, 24)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.rectBorder, style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                    )
                    Text("After Image")
                        .font(.system(size: 14).weight(.medium))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    VStack(spacing: 12){
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 24))
                        VStack(spacing: 4){
                            Text("Add Image")
                                .font(.system(size: 14).weight(.medium))
                            PhotosPicker("Click to upload an image (PDF, JPG, PNG)", selection: $viewModel.afterImage)
                                .font(.system(size: 10))
                                .foregroundStyle(Color.bodyText)
                        }
                    }
                    .padding(.vertical, 24)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.rectBorder, style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
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
                            await viewModel.confirmModification()
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
        .navigationTitle("Add a Modification")
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
            viewModel.onModificationReady = { modification in
                Task {
                    await detailViewModel.addModification(modification, vehicleId: vehicleId)
                    dismiss()
                }
            }
        }
    }
}

struct ModTypeDropdown: View {
    @Binding var selection: String
    let options: [String]

    var body: some View {
        Menu {
            ForEach(options, id: \.self) { type in
                Button {
                    selection = type
                } label: {
                    Text(type)
                }
            }
        } label: {
            HStack {
                Text(selection.isEmpty ? "Select" : selection)
                    .font(.system(size: 13))
                    .foregroundStyle(Color("lightBlack"))

                Spacer()

                Image(systemName: "chevron.down")
                    .padding(.trailing, 8)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.rectBorder, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview{
    //AddModificationView()
}
