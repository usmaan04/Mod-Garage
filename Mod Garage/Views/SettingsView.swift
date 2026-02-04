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
    @EnvironmentObject private var viewModel: SettingsViewModel
    
    @State private var isDarkToggleOn: Bool = false
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) private var systemColorScheme
    @AppStorage("preferredColorScheme") private var preferredColorSchemeRaw: String = "system"

    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                VStack(){
                    Image("AdaptiveLaunch")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
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
                    .font(.system(size: 17).weight(.semibold))
                
                VStack{
                    SettingComponent(
                        iconName: "person",
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
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color(.rectBorder), lineWidth: 1)
                        .fill(Color.boxbackground)
                )
                
                Text("Preferences")
                    .foregroundColor(.lightBlack)
                    .font(.system(size: 17).weight(.semibold))
                
                VStack{
                    SettingComponent(
                        iconName: "bell",
                        title: "Notifications",
                        toggleValue: .constant(false)
                    ) {
                        print("Go to Notification view")
                    }
                    Divider()
                    SettingComponent(
                        iconName: "moon",
                        title: "Dark Mode",
                        showsToggle: true,
                        toggleValue: Binding(
                            get: {
                                // Prefer the user choices in view model; otherwise mirror system appearance
                                if let override = viewModel.overrideColorScheme {
                                    return override == .dark
                                } else {
                                    return systemColorScheme == .dark
                                }
                            },
                            set: { newValue in
                                // Update view model override when user toggles
                                viewModel.overrideColorScheme = newValue ? .dark : .light
                            }
                        )
                    ) {
                        // No action need as toggle handles changes
                    }
                    .contextMenu{
                        Button("Follow System"){
                            viewModel.overrideColorScheme = nil
                        }
                    }
                }
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color(.rectBorder), lineWidth: 1)
                        .fill(Color.boxbackground)
                )
                
                Text("Support")
                    .foregroundColor(.lightBlack)
                    .font(.system(size: 17).weight(.semibold))
                
                VStack{
                    SettingComponent(
                        iconName: "shield",
                        title: "Privacy Policy",
                        toggleValue: .constant(false)
                    ) {
                        if let url = URL(string: "https://www.apple.com/legal/privacy/") {
                            openURL(url)
                        }
                    }
                    Divider()
                        .foregroundStyle(Color.rectBorder)
                        .frame(height: 1)
                    SettingComponent(
                        iconName: "ellipsis.bubble",
                        title: "Contact & Support",
                        toggleValue: .constant(false)
                    ) {
                        print("Go to Support view")
                    }
                    
                }
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color(.rectBorder), lineWidth: 1)
                        .fill(Color.boxbackground)
                )
                
                VStack{
                    Button(action: {
                        appViewModel.signOut()
                    }) {
                        Text("Log Out")
                            .font(.system(size: 14).weight(.semibold))
                            .foregroundColor(.redTheme)
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 18)
                    .frame(alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.redTheme).opacity(0.2), lineWidth: 1)
                            .fill(Color.boxbackground)
                    )
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                
            }
            .padding(.horizontal, 17)
            .frame(maxWidth: .infinity, maxHeight: .infinity ,alignment: .top)
            .background(Color.background)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $viewModel.showProfile) {
                ProfileView()
            }
            .alert(viewModel.alertMessage, isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) { }
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
                    RoundedRectangle(cornerRadius: 16)
                        .scaledToFit()
                        .padding(4)
                        .frame(width: 48, height: 48)
                        .foregroundStyle(Color.lightPink)
                    if iconName == "clipboard" || iconName == "shield"{
                        Image(systemName: iconName)
                            .resizable()
                            .font(.system(size:4))
                            .frame(width: 16, height: 20)
                            .foregroundStyle(Color.redTheme)
                    }else{
                        Image(systemName: iconName)
                            .resizable()
                            .font(.system(size:4))
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.redTheme)
                    }
                }
                
                
                Text(title)
                    .font(.system(size:15).weight(.semibold))
                    .foregroundColor(.lightBlack)
                
                Spacer()
                
                if showsToggle {
                    Toggle("", isOn: $toggleValue)
                        .labelsHidden()
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.navText)
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
            .environmentObject(SettingsViewModel())
    }
}

