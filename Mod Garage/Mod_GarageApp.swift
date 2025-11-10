//
//  Mod_GarageApp.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 20/10/2025.
//

import SwiftUI
import FirebaseCore

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

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environment(\.font, .custom("Archivo", size: 16))
        }
    }
}
