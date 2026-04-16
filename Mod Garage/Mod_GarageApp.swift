//
//  Mod_GarageApp.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 20/10/2025.
//

import SwiftUI
import FirebaseCore

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct Mod_GarageApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var toastManager = ToastManager()

    var body: some Scene {
        WindowGroup {
            ZStack {
                SplashScreenView()
                    .environmentObject(toastManager)

                // Overlay any toasties above all content
                ToastHost()
                    .environmentObject(toastManager)
            }
        }
    }
}
