//
//  AuthViewModel.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 10/11/2025.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var showLogin: Bool

    init(showLogin: Bool = true) {
        self.showLogin = showLogin
    }


    func toggleView() {
        showLogin.toggle()
    }
}
