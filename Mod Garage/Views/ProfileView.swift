//
//  ProfileView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 13/11/2025.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        VStack(spacing: 0){
            VStack(alignment: .leading, spacing: 16) {
                ZStack{
                    Image("AdaptiveLaunch")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150, alignment: .center)
                        .frame(maxWidth: .infinity)
                    
                    Button{
                        print("pressed")
                    }label:{
                        Image(systemName: "pencil")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(Color.white)
                    }
                    .padding(6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.redTheme)
                    )
                    .offset(x: 32, y: 36)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                        .font(.system(size: 14).weight(.medium))
                    TextField("Enter your name", text: $viewModel.name)
                        .autocorrectionDisabled()
                        .font(.system(size: 12))
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .padding(.vertical, 16)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.boxbackground)
                                .stroke(Color.rectBorder, lineWidth: 1)
                        )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.system(size: 14).weight(.medium))
                    TextField("Enter your email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .font(.system(size: 12))
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .padding(.vertical, 16)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.boxbackground)
                                .stroke(Color.rectBorder, lineWidth: 1)
                        )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.system(size: 14).weight(.medium))
                    SecureField("Enter a new password", text: $viewModel.password)
                        .font(.system(size: 12))
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .padding(.vertical, 16)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.boxbackground)
                                .stroke(Color.rectBorder, lineWidth: 1)
                        )
                }

                HStack(spacing: 12) {
                    
                    Button {
                        Task { await viewModel.loadProfile() }
                    } label: {
                        Text("Refresh")
                    }
                    .font(.system(size: 14).weight(.semibold))
                    .foregroundStyle(Color.redTheme)
                    .padding(.horizontal,10)
                    .padding(.vertical,16)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.redTheme, lineWidth: 1)
                    )
                    .disabled(viewModel.isLoading)
                    
                    Button {
                        Task { await viewModel.updateProfile() }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Save Changes")
                        }
                    }
                    .font(.system(size: 14).weight(.semibold))
                    .foregroundStyle(Color.backgroundW)
                    .padding(.horizontal,10)
                    .padding(.vertical,16)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.redTheme)
                    )
                    .disabled(viewModel.isLoading)
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 17)
            .frame(maxWidth: .infinity, alignment: .leading)
            .alert(viewModel.successMessage ?? "", isPresented: .constant(viewModel.successMessage != nil)) {
                Button("OK") { viewModel.successMessage = nil }
            } message: {
                Text(viewModel.successMessage ?? "")
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.background)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// Preview
#Preview {
    ProfileView()
}
