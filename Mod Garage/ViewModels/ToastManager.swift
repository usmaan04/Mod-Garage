//
//  ToastManager.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 15/04/2026.
//

import SwiftUI
import Combine

// hHandles the state and life of toasties acting as a ViewModel
@MainActor
final class ToastManager: ObservableObject {
    
    @Published var currentToast: AppToast?

    private var dismissTask: Task<Void, Never>?

    // Display toastie with message, style and duration
    func show(
        _ message: String,
        style: AppToast.Style = .info,
        duration: Double = 2.5
    ) {
        dismissTask?.cancel()

        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            currentToast = AppToast(message: message, style: style)
        }

        dismissTask = Task {
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }

            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                currentToast = nil
            }
        }
    }

    // Hides the toastie
    func hide() {
        dismissTask?.cancel()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            currentToast = nil
        }
    }
}
