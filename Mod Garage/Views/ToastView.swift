//
//  ToastView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 16/04/2026.
//

import SwiftUI

// Reusable component to style the toastie
struct ToastView: View {
    let toast: AppToast

    // Determines the icon to use based on style
    private var iconName: String {
        switch toast.style {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.octagon.fill"
        case .info: return "info.circle.fill"
        }
    }

        // Determines the colour to use based on the style
    private var accentColor: Color {
        switch toast.style {
        case .success: return .green
        case .error: return .redTheme
        case .info: return .yellow
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            
            // Icon
            Image(systemName: iconName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(accentColor)

            // Message
            Text(toast.message)
                .font(.system(size: 16, weight: .semibold))
                .fontWidth(.condensed)
                .foregroundStyle(Color.bw)
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.container)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.containerBorder, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        )
    }
}

// Preview to show the 3 styles of toasties
#Preview("ToastView Variants") {
    VStack(spacing: 12) {
        ToastView(
            toast: AppToast(
                message: "Saved successfully",
                style: .success)
        )
        ToastView(
            toast: AppToast(
                message: "Something went wrong",
                style: .error)
        )
        ToastView(
            toast: AppToast(
                message: "Heads up: Check your settings",
                style: .info)
        )
    }
    .padding()
    .background(Color.background)
}

