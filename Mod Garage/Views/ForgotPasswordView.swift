//
//  ForgotPassword.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 20/02/2026.
//

import Foundation
import SwiftUI

struct ForgotPasswordView: View {
    @StateObject var viewModel = ForgotPasswordViewModel()
    
    
    var body: some View{
        VStack(alignment: .center, spacing: 16){
            Text("Forgot Password")
                .font(.system(size: 24, weight: .semibold))
                .fontWidth(.condensed)
            
            Text("Enter the email associated with your account and we'll send you a link to reset it")
                .font(.system(size: 14))
                .tracking(-0.4)
                .foregroundColor(.containerText)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)

            TextField(
                "",
                text: $viewModel.email,
                prompt: Text("Enter email")
            )
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Color.containerText)
            .keyboardType(.asciiCapable)
            .multilineTextAlignment(.center)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.containerBorder, lineWidth: 1)
                    .fill(Color.container)
            )
            
            if viewModel.isLoading{
                ProgressView()
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: 13))
                    .foregroundStyle(.redTheme)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
            }
            
            if let alert = viewModel.alertMessage {
                Text(alert)
                    .font(.system(size: 13))
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                viewModel.forgotPassword()
            }) {
                Text("Send Reset Link")
                    .font(.system(size: 14).weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.redTheme)
                    .foregroundColor(.white)
                    .cornerRadius(100)
            }
            .disabled(viewModel.email.isEmpty)
            
        }
        .padding(.horizontal, 17)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    ForgotPasswordView()
}
