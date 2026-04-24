//
//  ToastHost.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 16/04/2026.
//

import SwiftUI

// Displays the toastie over all content
struct ToastHost: View {
    @EnvironmentObject var toastManager: ToastManager

    var body: some View {
        Color.clear
            .safeAreaInset(edge: .top) {
                if let toast = toastManager.currentToast {
                    ToastView(toast: toast)
                        .padding(.horizontal, 17)
                        .padding(.top, 8)
                        .transition(
                            .move(edge: .top)
                            .combined(with: .opacity)
                        )
                     
                    
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: toastManager.currentToast)
    }
}
