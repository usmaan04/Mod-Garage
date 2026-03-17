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
                VStack(spacing: 14){
                    Text("MOD NAME")
                        .font(.system(size: 12).weight(.medium))
                        .foregroundStyle(Color.navText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField(
                        "",
                        text: $viewModel.modName,
                        prompt: Text("Sport Exhaust System")
                            .foregroundStyle(Color.navText)
                    )
                    .font(.system(size: 14))
                    .keyboardType(.asciiCapable)
                    .textInputAutocapitalization(.never)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.rectBorder, lineWidth: 3)
                            .fill(Color.boxbackground)
                    )
                    Text("MOD TYPE")
                        .font(.system(size: 12).weight(.medium))
                        .foregroundStyle(Color.navText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ModTypeDropdown(selection: $viewModel.modType, options: viewModel.modTypes)
                    HStack{
                        Text("COST")
                            .font(.system(size: 12).weight(.medium))
                            .foregroundStyle(Color.navText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("INSTALL DATE")
                            .font(.system(size: 12).weight(.medium))
                            .foregroundStyle(Color.navText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    HStack{
                        TextField(
                            "",
                            value: $viewModel.modCost,
                            format: .currency(code: "GBP"),
                            prompt: Text("140.58")
                                .foregroundStyle(Color.navText)
                        )
                        .font(.system(size: 14))
                        .foregroundStyle(Color.lightBlack)
                        .keyboardType(.decimalPad)
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
                                Text(viewModel.modDate.formatted(date: .abbreviated, time: .omitted))
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
                                selection: $viewModel.modDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .presentationDetents([.medium])
                        }
                    }
                    Text("DESCRIPTION")
                        .font(.system(size: 12).weight(.medium))
                        .foregroundStyle(Color.navText)
                        .foregroundStyle(Color.navText)
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
                    .foregroundStyle(Color.navText)
                    .frame(height: 80, alignment: .leading)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.rectBorder, lineWidth: 3)
                            .fill(Color.boxbackground)
                    )
                    HStack{
                        Text("BEFORE IMAGE")
                            .font(.system(size: 12).weight(.medium))
                            .foregroundStyle(Color.navText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("AFTER IMAGE")
                            .font(.system(size: 12).weight(.medium))
                            .foregroundStyle(Color.navText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    HStack{
                        VStack(spacing: 12){
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 24))
                            VStack(spacing: 4){
                                Text("Add Image")
                                    .font(.system(size: 12).weight(.medium))
                                PhotosPicker("Click to upload an image (PDF, JPG, PNG)", selection: $viewModel.beforeImage)
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color.bodyText)
                            }
                        }
                        .padding(.vertical, 24)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.rectBorder, style: StrokeStyle(lineWidth: 3, dash: [6, 4]))
                                .fill(Color.boxbackground)
                        )
                        VStack(spacing: 12){
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 24))
                            VStack(spacing: 4){
                                Text("Add Image")
                                    .font(.system(size: 12).weight(.medium))
                                PhotosPicker("Click to upload an image (PDF, JPG, PNG)", selection: $viewModel.afterImage)
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color.bodyText)
                            }
                        }
                        .padding(.vertical, 24)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.rectBorder, style: StrokeStyle(lineWidth: 3, dash: [6, 4]))
                                .fill(Color.boxbackground)
                        )
                    }
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
            
            // link AddModificationViewModel → VehicleDetailViewModel
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
                    .font(.system(size: 14))
                    .foregroundStyle(Color.navText)

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
                    .stroke(Color.rectBorder, lineWidth: 3)
                    .fill(Color.boxbackground)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview{
    //AddModificationView()
}
