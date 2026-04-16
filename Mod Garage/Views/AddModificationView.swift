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
    @EnvironmentObject var toastManager: ToastManager
    
    let vehicleId: String
    
    var body: some View {
        VStack(spacing: 24){
            ScrollView{
                VStack(spacing: 14){
                    
                    // Name label and Field
                    Text("Name")
                        .font(.system(size: 16).weight(.medium))
                        .fontWidth(.condensed)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField(
                        "",
                        text: $viewModel.modName,
                        prompt: Text("Sport Exhaust System")
                            .foregroundStyle(Color.containerText)
                    )
                    .font(.system(size: 14))
                    .keyboardType(.asciiCapable)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.containerBorder, lineWidth: 3)
                            .fill(Color.container)
                    )
                    
                    // Type label and dropdown
                    Text("Type")
                        .font(.system(size: 16).weight(.medium))
                        .fontWidth(.condensed)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ModTypeDropdown(selection: $viewModel.modType, options: viewModel.modTypes)
                    
                    // Cost, date label and field
                    HStack{
                        Text("Cost")
                            .font(.system(size: 16).weight(.medium))
                            .fontWidth(.condensed)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Install Date")
                            .font(.system(size: 16).weight(.medium))
                            .fontWidth(.condensed)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    HStack{
                        TextField(
                            "",
                            value: $viewModel.modCost,
                            format: .currency(code: "GBP"),
                            prompt: Text("140.58")
                                .foregroundStyle(Color.containerText)
                        )
                        .font(.system(size: 14))
                        .foregroundStyle(Color.containerText)
                        .keyboardType(.decimalPad)
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
                                Text(viewModel.modDate.formatted(date: .abbreviated, time: .omitted))
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
                        // Date sheet
                        .sheet(isPresented: $viewModel.showDatePicker) {
                            DatePicker(
                                "Select date",
                                selection: $viewModel.modDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .presentationDetents([.medium])
                        }
                    }
                    
                    // Description label and field
                    Text("Description")
                        .font(.system(size: 16).weight(.medium))
                        .fontWidth(.condensed)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ZStack(alignment: .top){
                        TextEditor(
                            text: $viewModel.modDesc)
                        
                        .font(.system(size: 14))
                        .tracking(-0.2)
                        .keyboardType(.asciiCapable)
                        
                        if viewModel.modDesc == "" {
                            Text("Enter description, include part numbers, seller details or installation notes here")
                                .tracking(-0.2)
                                .frame(maxWidth: .infinity, alignment:.leading)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 8)
                        }
                    
                    }
                    .font(.system(size: 13))
                    .foregroundStyle(Color.containerText)
                    .frame(height: 80, alignment: .leading)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.containerBorder, lineWidth: 3)
                            .fill(Color.container)
                    )
                    
                    // Images label and field
                    HStack{
                        Text("Before Image")
                            .font(.system(size: 16).weight(.medium))
                            .fontWidth(.condensed)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("After Image")
                            .font(.system(size: 16).weight(.medium))
                            .fontWidth(.condensed)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    HStack{
                        
                        // Before image
                        VStack(spacing: 12){
                            if let selectedImage = viewModel.beforeImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }else{
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 24))
                            }
                            VStack(spacing: 4){
                                Text("Add Image")
                                    .font(.system(size: 12).weight(.medium))
                                PhotosPicker("Click to upload an image", selection: $viewModel.beforeImageItem, matching: .images)
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color.containerText)
                                    .onChange(of: viewModel.beforeImageItem) { _ in
                                        Task {
                                            await viewModel.loadBeforeImage()
                                        }
                                    }
                            }
                        }
                        .padding(.vertical, 24)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.containerBorder, style: StrokeStyle(lineWidth: 3, dash: [6, 4]))
                                .fill(Color.container)
                        )
                        
                        // After image
                        VStack(spacing: 12){
                            if let selectedImage = viewModel.afterImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }else{
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 24))
                            }
                            VStack(spacing: 4){
                                Text("Add Image")
                                    .font(.system(size: 12).weight(.medium))
                                PhotosPicker("Click to upload an image", selection: $viewModel.afterImageItem, matching: .images)
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color.containerText)
                                    .onChange(of: viewModel.afterImageItem) { _ in
                                        Task {
                                            await viewModel.loadAfterImage()
                                        }
                                    }
                            }
                        }
                        .padding(.vertical, 24)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.containerBorder, style: StrokeStyle(lineWidth: 3, dash: [6, 4]))
                                .fill(Color.container)
                        )
                    }
                }
                .padding(.horizontal,17)
                
                // Error message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.redTheme)
                        .multilineTextAlignment(.center)
                }
                
                // Save button
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
                .padding(.horizontal,17)
                .padding(.top, 24)
            }
            .frame(maxHeight: .infinity)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .navigationTitle("Add a Modification")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.background)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading){
                Button(role: .cancel) {
                    dismiss()
                }
            }
        }
        .onAppear {
            viewModel.vehicleId = vehicleId
            // Link AddModificationViewModel to VehicleDetailViewModel to add modifications
            viewModel.onModificationReady = { modification in
                Task {
                    await detailViewModel.addModification(modification, vehicleId: vehicleId)
                    dismiss()
                    toastManager.show("Modification added successfully", style: .success)
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}

// Separate dropdown structre
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
                    .font(.system(size: 14))
                    .foregroundStyle(Color.containerText)

                Spacer()

                Image(systemName: "chevron.down")
                    .padding(.trailing, 8)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.containerBorder, lineWidth: 3)
                    .fill(Color.container)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

