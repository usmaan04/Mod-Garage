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
            VStack(alignment: .leading, spacing: 14) {
                HStack(){
                    Image("AdaptiveLaunch")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 54, height: 54)
                    VStack(spacing:4){
                        if viewModel.name.isEmpty {
                            ProgressView("Loading...")
                                .padding()
                        } else {
                            Text("\(viewModel.name)")
                                .font(.system(size: 16).weight(.semibold))
                                .tracking(-0.2)
                                .foregroundColor(Color.lightBlack)
                                .frame(maxWidth: .infinity,alignment: .leading)
                            Text("\(viewModel.email)")
                                .font(.system(size: 12))
                                .tracking(-0.2)
                                .foregroundColor(Color.bodyText)
                                .frame(maxWidth: .infinity,alignment: .leading)
                        }
                    }
                    Button(action: {
                        appViewModel.signOut()
                    }) {
                        Text("Log Out")
                            .font(.system(size: 14))
                            .padding(.trailing, 6)
                            .foregroundColor(.redTheme)
                    }
                    
                }
                .padding(8)
                .frame(maxWidth: .infinity, maxHeight: 72)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.rectFill)
                )
                    
                Text("General")
                    .foregroundColor(.lightBlack)
                    .font(.system(size: 17).weight(.semibold))
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
                SettingComponent(
                    iconName: "bell",
                    title: "Notifications",
                    toggleValue: .constant(false)
                ) {
                    print("Go to Notification view")
                }
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
                    
                Text("Legal")
                    .foregroundColor(.lightBlack)
                    .font(.system(size: 17).weight(.semibold))
                SettingComponent(
                    iconName: "shield",
                    title: "Privacy Policy",
                    toggleValue: .constant(false)
                ) {
                    if let url = URL(string: "https://www.apple.com/legal/privacy/") {
                        openURL(url)
                    }
                }
                SettingComponent(
                    iconName: "clipboard",
                    title: "Terms of Use",
                    toggleValue: .constant(false)
                ) {
                    if let url = URL(string: "https://www.apple.com/legal/internet-services/terms/site.html") {
                        openURL(url)
                    }
                }
                Text("Support")
                    .foregroundColor(.lightBlack)
                    .font(.system(size: 17).weight(.semibold))
                SettingComponent(
                    iconName: "ellipsis.bubble",
                    title: "Contact & Support",
                    toggleValue: .constant(false)
                ) {
                    print("Go to Support view")
                }
                Text("Delete")
                    .foregroundColor(.lightBlack)
                    .font(.system(size: 17).weight(.semibold))
                SettingComponent(
                    iconName: "trash",
                    title: "Delete Account",
                    isDestructive: true,
                    toggleValue: .constant(false)
                ) {
                    print("Delete Account")
                }
                
            }
            .padding(.horizontal, 17)
            .background(Color.background)
            .frame(maxWidth: .infinity, maxHeight: .infinity ,alignment: .top)
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
                if iconName == "clipboard" || iconName == "shield"{
                    Image(systemName: iconName)
                        .resizable()
                        .font(.system(size:4))
                        .frame(width: 16, height: 20)
                        .foregroundStyle(isDestructive ? .redTheme : .lightBlack)
                }else{
                    Image(systemName: iconName)
                        .resizable()
                        .font(.system(size:4))
                        .frame(width: 20, height: 20)
                        .foregroundStyle(isDestructive ? .redTheme : .lightBlack)
                }
                
                Text(title)
                    .font(.system(size:16))
                    .tracking(-0.1)
                    .foregroundColor(.lightBlack)
                
                Spacer()
                
                if showsToggle {
                    Toggle("", isOn: $toggleValue)
                        .labelsHidden()
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.redTheme)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 46)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.rectBorder), lineWidth: 1)
                    .fill(Color.boxbackground)
            )
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
