//
//  SettingsView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 11/11/2025.
//

import Foundation
import SwiftUI
import Combine

struct SettingsView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @EnvironmentObject private var vehicleViewModel: VehicleViewModel
    @EnvironmentObject private var viewModel: SettingsViewModel
    
    @State private var isDarkToggleOn: Bool = false
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) private var systemColorScheme
    @AppStorage("preferredColorScheme") private var preferredColorSchemeRaw: String = "system"

    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0){
                VStack{
                    Text("Settings")
                        .foregroundStyle(Color.lightBlack)
                        .font(.system(size: 18).weight(.semibold))
                        .padding(.bottom, 12)
                }
                .zIndex(30)
                .frame(maxWidth:.infinity, maxHeight: 48)
                .background(Color.backgroundW)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                
                GeometryReader{ proxy in
                    ScrollView{
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(){
                                if let photoURL = viewModel.profilePhotoURL {
                                    AsyncImage(url: photoURL) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 64, height: 64)

                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipShape(Circle())

                                        case .failure(_):
                                            Image("AdaptiveLaunch")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 64, height: 64)
                                                .clipShape(Circle())

                                        @unknown default:
                                            Image("AdaptiveLaunch")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 64, height: 64)
                                                .clipShape(Circle())
                                        }
                                    }
                                } else {
                                    Image("AdaptiveLaunch")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 64, height: 64)
                                        .clipShape(Circle())
                                }
                                VStack(spacing:4){
                                    if viewModel.name.isEmpty {
                                        ProgressView("Loading...")
                                            .padding()
                                    } else {
                                        Text("\(viewModel.name)")
                                            .font(.system(size: 18).weight(.semibold))
                                            .foregroundColor(Color.lightBlack)
                                            .frame(maxWidth: .infinity,alignment: .center)
                                    }
                                    Text("Member since \(viewModel.memberDate)")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color.navText)
                                        .frame(maxWidth: .infinity,alignment: .center)
                                }
                                
                            }
                                
                            Text("General")
                                .foregroundColor(.lightBlack)
                                .font(.system(size: 16).weight(.semibold))
                            
                            VStack{
                                SettingComponent(
                                    iconName: "person.fill",
                                    title: "Profile",
                                    toggleValue: .constant(false)
                                ) {
                                    if viewModel.isEmailPasswordUser {
                                            viewModel.showProfile = true
                                    } else {
                                        viewModel.alertMessage = "Your profile details are managed by Google. You cannot edit your name or email here."
                                        viewModel.showAlert = true
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color(.rectBorder), lineWidth: 2)
                                    .fill(Color.boxbackground)
                                    .shadow(color: Color.black.opacity(0.05),radius: 3, x: 0, y: 2)
                            )
                            
                            Text("Preferences")
                                .foregroundColor(.lightBlack)
                                .font(.system(size: 16).weight(.semibold))
                            
                            VStack{
                                SettingComponent(
                                    iconName: "bell.fill",
                                    title: "Notifications",
                                    toggleValue: .constant(false)
                                ) {
                                    viewModel.showNotification = true
                                }
                                Divider()
                                HStack(spacing: 0) {
                                    Button(action: {}) {
                                        HStack(spacing: 14) {
                                            ZStack{
                                                Circle()
                                                    .scaledToFit()
                                                    .padding(4)
                                                    .frame(width: 48, height: 48)
                                                    .foregroundStyle(Color.lightPink)
                                                Image(systemName: "moon.fill")
                                                    .resizable()
                                                    .font(.system(size:4))
                                                    .frame(width: 16, height: 16)
                                                    .foregroundStyle(Color.redTheme)
                                            }

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Theme")
                                                    .font(.system(size: 14).weight(.semibold))
                                                    .foregroundColor(.lightBlack)
                                                // Show current selection label
                                                Text({ () -> String in
                                                    if let override = viewModel.overrideColorScheme {
                                                        return override == .dark ? "Dark" : "Light"
                                                    } else {
                                                        return "System"
                                                    }
                                                }())
                                                .font(.system(size: 12))
                                                .foregroundColor(.navText)
                                            }

                                            Spacer()

                                            Menu {
                                                Button("Follow System") { viewModel.overrideColorScheme = nil }
                                                Button("Light") { viewModel.overrideColorScheme = .light }
                                                Button("Dark") { viewModel.overrideColorScheme = .dark }
                                            } label: {
                                                HStack(spacing: 6) {
                                                    Text({ () -> String in
                                                        if let override = viewModel.overrideColorScheme {
                                                            return override == .dark ? "Dark" : "Light"
                                                        } else {
                                                            return "System"
                                                        }
                                                    }())
                                                    .font(.system(size: 14))
                                                    .foregroundStyle(Color.navText)
                                                    Image(systemName: "chevron.down")
                                                        .font(.system(size: 12))
                                                        .foregroundStyle(Color.navText.opacity(0.6))
                                                }
                                                .contentShape(Rectangle())
                                            }
                                        }
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 0)
                                        .frame(maxWidth: .infinity, minHeight: 46)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color(.rectBorder), lineWidth: 2)
                                    .fill(Color.boxbackground)
                                    .shadow(color: Color.black.opacity(0.05),radius: 3, x: 0, y: 2)
                            )
                            
                            Text("Support")
                                .foregroundColor(.lightBlack)
                                .font(.system(size: 16).weight(.semibold))
                            
                            VStack{
                                SettingComponent(
                                    iconName: "shield.fill",
                                    title: "Privacy Policy",
                                    toggleValue: .constant(false)
                                ) {
                                    if let url = URL(string: "https://www.apple.com/legal/privacy/") {
                                        openURL(url)
                                    }
                                }
                                Divider()
                                    .foregroundStyle(Color.rectBorder)
                                    .frame(height: 2)
                                SettingComponent(
                                    iconName: "questionmark.circle.fill",
                                    title: "Contact & Support",
                                    toggleValue: .constant(false)
                                ) {
                                    if let url = URL(string: "https://www.modgarage.com") {
                                        openURL(url)
                                    }
                                }
                                
                            }
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color(.rectBorder), lineWidth: 2)
                                    .fill(Color.boxbackground)
                                    .shadow(color: Color.black.opacity(0.05),radius: 3, x: 0, y: 2)
                            )
                            
                            VStack{
                                HStack{
                                    Button(action: {
                                        appViewModel.signOut()
                                    }) {
                                        Text("Log Out")
                                    }
                                    .padding(.horizontal, 28)
                                    .padding(.vertical, 18)
                                    .foregroundStyle(.redTheme)
                                    .font(.system(size: 14).weight(.semibold))
                                    .frame(alignment: .center)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(.redTheme).opacity(0.2), lineWidth: 1)
                                            .fill(Color.boxbackground)
                                    )
                                    
                                    Button(action: {
                                        appViewModel.deleteAccountSafely()
                                    }) {
                                        Text("Delete Account")
                                    }
                                    .padding(.horizontal, 28)
                                    .padding(.vertical, 18)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 14).weight(.semibold))
                                    .frame(alignment: .center)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.redTheme)
                                    )
                                }
                            }
                            .padding(.top, 16)
                            .frame(maxWidth: .infinity, alignment: .center)
                            
                            
                        }
                        .padding(.horizontal, 17)
                        .padding(.vertical, 16)
                    }
                    .frame(maxHeight: proxy.size.height - 48)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity ,alignment: .top)
            .background(Color.background)
            .navigationDestination(isPresented: $viewModel.showProfile) {
                ProfileView()
                    .environmentObject(homeViewModel)
                    .environmentObject(viewModel)

            }
            .navigationDestination(isPresented: $viewModel.showNotification) {
                NotificationView(
                    viewModel: NotificationViewModel(
                        vehicleProvider: { vehicleViewModel.vehicles }
                    )
                )
            }
            .alert(viewModel.alertMessage, isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) { }
            }
            .task {
                await vehicleViewModel.loadVehicles()
            }
        }
    }
}

struct SettingComponent: View {
    var iconName: String
    var title: String
    var isDestructive: Bool = false
    var showsToggle: Bool = false
    @Binding var toggleValue: Bool
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: 14) {
                ZStack{
                    Circle()
                        .scaledToFit()
                        .padding(4)
                        .frame(width: 48, height: 48)
                        .foregroundStyle(Color.lightPink)
                    if iconName == "shield.fill"{
                        Image(systemName: iconName)
                            .resizable()
                            .font(.system(size:4))
                            .frame(width: 14, height: 16)
                            .foregroundStyle(Color.redTheme)
                    }else{
                        Image(systemName: iconName)
                            .resizable()
                            .font(.system(size:4))
                            .frame(width: 16, height: 16)
                            .foregroundStyle(Color.redTheme)
                    }
                }
                
                
                Text(title)
                    .font(.system(size: 14).weight(.semibold))
                    .foregroundColor(.lightBlack)
                
                Spacer()
                
                if showsToggle {
                    Toggle("", isOn: $toggleValue)
                        .labelsHidden()
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.navText.opacity(0.3))
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 0)
            .frame(maxWidth: .infinity, minHeight: 46)
        }
    }
}

// Preview
#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AppViewModel())
            .environmentObject(HomeViewModel())
            .environmentObject(VehicleViewModel())
            .environmentObject(SettingsViewModel())
    }
}

