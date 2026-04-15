//
//  OnboardingProgressViewModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 12/04/2026.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var progress: Double = 0.0

    // Set a custom bar value
    func setProgress(to value: Double) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            self.progress = value
        }
    }
    
    // Helper to set values for pre-set steps
    func updateForStep(_ step: Int) {
        switch step {
        case 1: setProgress(to: 0.33)
        case 2: setProgress(to: 0.66)
        case 3: setProgress(to: 0.33) 
        default: setProgress(to: 0.0)
        }
    }
}
