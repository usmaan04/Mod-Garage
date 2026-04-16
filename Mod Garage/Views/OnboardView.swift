//
//  WelcomeView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 11/04/2026.
//

import Foundation
import SwiftUI
import PhotosUI

struct OnboardView: View {
    @ObservedObject var authVM: AuthViewModel
    
    // View models
    @StateObject private var signUpVM = SignUpViewModel()
    @StateObject private var loginVM = LoginViewModel()
    @StateObject private var addVehicleVM = AddVehicleViewModel()
    @StateObject private var vehicleViewModel = VehicleViewModel()
    @StateObject private var onboardVM = OnboardingViewModel()
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                
                // Background image
                Image("audi")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: 340)
                    .clipped()
                    .ignoresSafeArea(edges: .top)
                
                // Gradient
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.clear, location: 0.0),
                        .init(color: Color.background.opacity(0.2), location: 0.25),
                        .init(color: Color.background.opacity(0.6), location: 0.3),
                        .init(color: Color.background.opacity(1), location: 0.35)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    
                    // progress bar
                    if authVM.currentStep > 0 {
                        ProgressBar(progress: onboardVM.progress)
                            .transition(.opacity)
                    }
                    
                    // Main onboard content display
                    Group{
                        // Displays relevant content based on teh current step value
                        switch authVM.currentStep {
                        case 0:
                            welcomeContent
                                .transition(.asymmetric(
                                    insertion: .move(edge: .leading),
                                    removal: .move(edge: .leading)
                                ))
                        case 1:
                            signUpContent
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing),
                                    removal: .move(edge: .trailing)
                                ))
                        case 2:
                            vehicleOnboardingContent
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing),
                                    removal: .move(edge: .trailing)
                                ))
                        case 3:
                            logInContent
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing),
                                    removal: .move(edge: .trailing)
                                ))
                        default:
                            EmptyView()
                        }
                    }
                    .id(authVM.currentStep)
                    .padding(.horizontal, 24)

                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 260)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: authVM.currentStep)
            }
        }
        .onAppear {
            // Link your vehicle logic
            addVehicleVM.onVehicleReady = { vehicle in
                Task {
                    await vehicleViewModel.addVehicle(vehicle)
                    authVM.finishOnboarding()
                }
            }
        }
        .onChange(of: authVM.currentStep) { oldStep, newStep in
            onboardVM.updateForStep(newStep)
        }
    }

    // MARK: - Onboard Views
    
    // First welcome screen content
    private var welcomeContent: some View {
        VStack(alignment: .leading, spacing: 60){
            VStack(spacing: 30){
                VStack(spacing: -16) {
                    
                    // Title 1
                    Text("WELCOME TO")
                        .font(.system(size: 54).weight(.medium))
                        .tracking(-1)
                        .fontWidth(.condensed)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Title 2
                    Text("MOD GARAGE")
                        .font(.system(size: 48).weight(.medium))
                        .fontWidth(.condensed)
                        .foregroundStyle(.redTheme)
                        .tracking(-1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Prompt
                Text("Track your builds, log your fuel, and manage your collection all in one high performance garage designed for the driven.")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.containerText)
                    .lineSpacing(8)
                    .tracking(0.2)
                    .frame(alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
            
            // Next step button
            Button {
                authVM.nextStep()
            } label: {
                HStack(spacing: 44) {
                    Text("START YOUR ENGINE")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "arrow.right")
                }
            }
            .padding(.horizontal, 52)
            .padding(.vertical, 24)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .background(Capsule().fill(.redTheme))
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            
        }
    }
    
    // Log in content
    private var logInContent: some View{
        VStack(spacing: 20) {
            
            // Title
            Text("Log In")
                .font(.system(size: 34).weight(.medium))
                .tracking(-1)
                .fontWidth(.condensed)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Email label and field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.system(size: 16).weight(.medium))
                    .fontWidth(.condensed)
                TextField(
                        "",
                        text: $loginVM.email,
                        prompt: Text("Enter your email here...")
                            .foregroundStyle(Color.containerText)
                    )
                    .font(.system(size: 12))
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.container)
                            .stroke(Color.containerBorder, lineWidth: 1)
                    )
            }
            
            // Password label and field
            VStack(alignment: .leading, spacing: 8) {
                HStack{
                    Text("Password")
                        .font(.system(size: 16).weight(.medium))
                        .fontWidth(.condensed)
                    // Forgot Password
                    Button {
                        authVM.showForgot()
                    } label: {
                        HStack(spacing: 6) {
                            Text("Forgot password?")
                                .foregroundStyle(Color.redTheme)
                                .font(.system(size: 15).weight(.semibold))
                                .fontWidth(.condensed)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .buttonStyle(.plain)
                    
                }
                HStack {
                    if loginVM.isPasswordVisible {
                        TextField(
                            "",
                            text: $loginVM.password,
                            prompt: Text("••••••••")
                                .foregroundStyle(Color.containerText)
                        )
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.asciiCapable)
                        .font(.system(size: 12))
                    } else {
                        SecureField(
                            "",
                            text: $loginVM.password,
                            prompt: Text("••••••••")
                                .foregroundStyle(Color.containerText)
                        )
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.asciiCapable)
                        .font(.system(size: 12))
                    }

                    Button(action: {
                        loginVM.isPasswordVisible.toggle()
                    }) {
                        Image(systemName: loginVM.isPasswordVisible ? "eye" : "eye.slash")
                            .foregroundStyle(Color.containerText)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.container)
                        .stroke(Color.containerBorder, lineWidth: 1)
                )
            }
            
            // Error Message
            if let loginError = loginVM.loginError {
                Text(loginError)
                    .font(.system(size: 14))
                    .tracking(-0.4)
                    .foregroundColor(.redTheme)
                    .padding(4)
            }
            
            HStack {
                // Login Button
                Button(action: {
                    authVM.finishOnboarding()
                    loginVM.login()
                }) {
                    if loginVM.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.redTheme)
                            .cornerRadius(100)
                    } else {
                        Text("Log In")
                            .font(.system(size: 12).weight(.bold))
                            .fontWidth(.condensed)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.redTheme)
                            .foregroundColor(.white)
                            .cornerRadius(100)
                    }
                }
                
                // Or divider
                Text("Or")
                    .font(.system(size: 14).weight(.medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 6)
                
                // Google Sign Up button
                Button(action: {
                    authVM.finishOnboarding()
                    loginVM.signInWithGoogle()
                }) {
                    HStack(spacing: 12) {
                        Image("google")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Log In with Google")
                            .font(.system(size: 10).weight(.medium))
                            .fontWidth(.condensed)
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(
                        Color(UIColor { trait in
                            trait.userInterfaceStyle == .dark
                                ? .white
                            : .black
                        })
                    )
                    .padding(.vertical, 16)
                    .background(
                        Color(UIColor { trait in
                            trait.userInterfaceStyle == .dark
                                ? .black
                            : .white
                        })
                    )
                    .cornerRadius(100)
                }
            }
            
            Spacer()
                            
            // Footer button to switch to sign up
            Button(action: { authVM.currentStep = 1 }) {
                HStack(spacing: 4) {
                    Text("Dont have an account? ")
                        .foregroundStyle(Color.containerText)
                    Text("SIGN UP")
                        .foregroundStyle(Color.redTheme)
                        .fontWeight(.semibold)
                        .fontWidth(.condensed)
                }
                .font(.footnote)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 20)
        }
    }

    // Sign up content
    private var signUpContent: some View {
        VStack(spacing: 20) {
            
            // Title
            Text("Create Account")
                .font(.system(size: 34).weight(.medium))
                .tracking(-1)
                .fontWidth(.condensed)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Name label and field
            VStack(alignment: .leading, spacing: 8) {
                Text("Name")
                    .font(.system(size: 16).weight(.medium))
                    .fontWidth(.condensed)
                TextField(
                    "",
                    text: $signUpVM.name,
                    prompt: Text("Enter your name here...")
                        .foregroundStyle(Color.containerText)
                )
                .font(.system(size: 12))
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .padding(.vertical, 16)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.container)
                        .stroke(Color.containerBorder, lineWidth: 1)
                )
            }
            
            // Email label and field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.system(size: 16).weight(.medium))
                    .fontWidth(.condensed)
                TextField(
                    "",
                    text: $signUpVM.email,
                    prompt: Text("Enter your email here...")
                        .foregroundStyle(Color.containerText)
                )
                .font(.system(size: 12))
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.vertical, 16)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.container)
                        .stroke(Color.containerBorder, lineWidth: 1)
                )
            }
            
            // Password label and field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.system(size: 16).weight(.medium))
                    .fontWidth(.condensed)
                SecureField(
                    "",
                    text: $signUpVM.password,
                    prompt: Text("••••••••")
                        .foregroundStyle(Color.containerText)
                )
                .font(.system(size: 12))
                .padding(.vertical, 16)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.container)
                        .stroke(Color.containerBorder, lineWidth: 1)
                )
            }
            
            // Error message
            if let signUpError = signUpVM.signUpError {
                Text(signUpError)
                    .font(.system(size: 14))
                    .tracking(-0.4)
                    .foregroundColor(.redTheme)
                    .padding(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack {
                
                // Sign up button
                Button(action: {
                    Task {
                        await signUpVM.register()
                        if signUpVM.isUserLoggedIn {
                            authVM.nextStep()
                        }
                    }
                }) {
                    Text("Sign Up")
                        .font(.system(size: 12).weight(.bold))
                        .fontWidth(.condensed)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.redTheme)
                        .foregroundColor(.white)
                        .cornerRadius(100)
                }
                
                // Or divider
                Text("Or")
                    .font(.system(size: 14).weight(.medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 6)
                
                // Google Sign Up Button
                Button(action: {
                    Task {
                        await signUpVM.signUpWithGoogle()
                        if signUpVM.isUserLoggedIn {
                            authVM.nextStep()
                        }
                    }
                }) {
                    HStack(spacing: 12) {
                        Image("google")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Sign Up with Google")
                            .font(.system(size: 10).weight(.medium))
                            .fontWidth(.condensed)
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(
                        Color(UIColor { trait in
                            trait.userInterfaceStyle == .dark
                                ? .white
                            : .black
                        })
                    )
                    .padding(.vertical, 16)
                    .background(
                        Color(UIColor { trait in
                            trait.userInterfaceStyle == .dark
                                ? .black
                            : .white
                        })
                    )
                    .cornerRadius(100)
                }
                
            }
            
            Spacer()
                            
            // Footer button to switch to log in
            Button(action: { authVM.currentStep = 3 }) {
                HStack(spacing: 4) {
                    Text("Already a member?")
                        .foregroundStyle(Color.containerText)
                    Text("LOG IN")
                        .foregroundStyle(Color.redTheme)
                        .fontWeight(.semibold)
                        .fontWidth(.condensed)
                }
                .font(.footnote)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 20)
            
        }
        
    }

    // Add vehicle content
    private var vehicleOnboardingContent: some View {
        VStack(spacing: 16){
            
            // MARK: - If is loading
            if addVehicleVM.isLoading {
                VStack(alignment: .center){
                    ProgressView("Searching DVLA...")
                }
                .frame(maxWidth: .infinity, alignment: .center)
            
            // MARK: - Show the returned DVLA details if there is a vehicle model
            } else if let dvla = addVehicleVM.dvlaVehicle, !addVehicleVM.hasConfirmedDVLA {
                VStack(spacing: 16) {
                    Text("Is this your vehicle?")
                        .font(.system(size: 22).weight(.medium))
                    
                    Text("\(dvla.registrationNumber)")
                        .font(.system(size: 16).weight(.bold))
                        .padding(.vertical, 16)
                        .padding(.horizontal, 50)
                        .foregroundStyle(Color.black)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 1)
                                .fill(Color.yellow)
                        )
                        .frame(maxWidth: .infinity)
                    
                    Text("\(dvla.make.sentenceCased)")
                        .font(.system(size: 18))
                        .frame(maxWidth: .infinity)
                        .fontWidth(.condensed)
                    
                    HStack{
                        HStack{
                            Image(systemName: "paintbrush")
                                .font(.system(size: 22))
                            Text("\(dvla.colour.sentenceCased)")
                                .font(.system(size: 18))
                                .fontWidth(.condensed)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        HStack{
                            Image(systemName: "calendar")
                                .font(.system(size: 22))
                            Text("\(dvla.yearOfManufacture.map(String.init) ?? "-")")
                                .font(.system(size: 20))
                                .fontWidth(.condensed)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                    }
                    .padding(4)
                    .frame(maxWidth: .infinity)
                    
                    HStack{
                        Button(action: {
                            addVehicleVM.dvlaVehicle = nil
                            onboardVM.setProgress(to: 0.66)
                        }) {
                            Text("No")
                                .font(.system(size: 16).weight(.bold))
                                .fontWidth(.condensed)
                                .frame(maxWidth: .infinity)
                                .padding(14)
                                .foregroundColor(.redTheme)
                        }
                        .background(
                            RoundedRectangle(
                                cornerRadius: 12,
                                style: .continuous
                            )
                            .stroke(Color.containerBorder)
                        )
                    
                        Button(action: {
                            addVehicleVM.hasConfirmedDVLA = true
                            onboardVM.setProgress(to: 0.9)
                        }) {
                            Text("Yes")
                                .font(.system(size: 16).weight(.bold))
                                .fontWidth(.condensed)
                                .frame(maxWidth: .infinity)
                                .padding(14)
                                .foregroundColor(.white)
                        }
                        .background(addVehicleVM.registration.isEmpty ? Color.gray : Color.redTheme)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .disabled(addVehicleVM.registration.isEmpty)
                        
                    }
                }
                
            // MARK: - Show  the returned DVLA details
            }else if addVehicleVM.hasConfirmedDVLA{
                VStack(spacing: 16) {
                    Text("Almost There")
                        .font(.system(size: 34).weight(.medium))
                        .tracking(-1)
                        .fontWidth(.condensed)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    HStack{
                        TextField(
                            "",
                            text: $addVehicleVM.model,
                            prompt: Text("Golf")
                                .foregroundStyle(Color.containerText)
                        )
                        .font(.system(size: 12, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .keyboardType(.asciiCapable)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.containerBorder)
                                
                        )
                        
                        VStack(spacing: 8){
                            if let selectedImage = addVehicleVM.carImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            PhotosPicker("Upload image", selection: $addVehicleVM.carImageItem, matching: .images)
                                .font(.system(size: 16).weight(.regular))
                                .fontWidth(.condensed)
                                .foregroundStyle(Color.containerText)
                                .onChange(of: addVehicleVM.carImageItem) { _ in
                                    Task {
                                        await addVehicleVM.loadImage()
                                    }
                                }
                                .frame(maxWidth: .infinity)
                        }
                    }

                    HStack{
                        Button("Back") {
                            addVehicleVM.hasConfirmedDVLA = false
                            onboardVM.setProgress(to: 0.8)
                        }
                        .font(.system(size: 16).weight(.bold))
                        .fontWidth(.condensed)
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .foregroundColor(.redTheme)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 12,
                                style: .continuous
                            )
                            .stroke(Color.containerBorder)
                        )
                        
                        Button(action: {
                            Task { await addVehicleVM.confirmVehicle() }
                            onboardVM.setProgress(to: 1.0)
                        }) {
                            Text("Add Vehicle")
                                .font(.system(size: 16).weight(.bold))
                                .fontWidth(.condensed)
                                .frame(maxWidth: .infinity)
                                .padding(14)
                                .foregroundColor(.white)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.redTheme)
                        )
                    }
                }
                
            // MARK: - Show  the returnedregular first add vehicle form
            }else{
                VStack(alignment: .center, spacing: 20) {
                    
                    Text("Final Step!")
                        .font(.system(size: 34).weight(.medium))
                        .tracking(-1)
                        .fontWidth(.condensed)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text("Enter Vehicle Registration")
                        .font(.system(size: 22))
                    
                    TextField(
                        "",
                        text: $addVehicleVM.registration,
                        prompt: Text("AB12 CDE")
                            .foregroundStyle(.black.opacity(0.3))
                    )
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.black)
                    .multilineTextAlignment(.center)
                    .autocorrectionDisabled(true)
                    .keyboardType(.asciiCapable)
                    .autocapitalization(.allCharacters)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black, lineWidth: 5)
                            .fill(Color.yellow)
                    )
                    
                    // Error message
                    if let errorMessage = addVehicleVM.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.top, 8)
                            .multilineTextAlignment(.center)
                    }
                    
                    HStack{
                        Button(action: {
                            onboardVM.setProgress(to: 1.0)
                            authVM.finishOnboarding()
                        }) {
                            Text("Add Later")
                                .font(.system(size: 16).weight(.bold))
                                .fontWidth(.condensed)
                                .frame(maxWidth: .infinity)
                                .padding(14)
                                .foregroundColor(.redTheme)
                        }
                        .background(
                            RoundedRectangle(
                                cornerRadius: 12,
                                style: .continuous
                            )
                            .stroke(Color.containerBorder)
                        )
                    
                        Button(action: {
                            addVehicleVM.searchRegistration()
                            onboardVM.setProgress(to: 0.80)
                        }) {
                            Text("Search")
                                .font(.system(size: 16).weight(.bold))
                                .fontWidth(.condensed)
                                .frame(maxWidth: .infinity)
                                .padding(14)
                                .foregroundColor(.white)
                        }
                        .background(addVehicleVM.registration.isEmpty ? Color.gray : Color.redTheme)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .disabled(addVehicleVM.registration.isEmpty)
                        
                    }
                }
            }
        }
        .onAppear {
            // Link the save action to VehicleViewModel
            addVehicleVM.onVehicleReady = { vehicle in
                Task {
                    await vehicleViewModel.addVehicle(vehicle)
                    // Finish onboaridng and move to home
                    authVM.finishOnboarding()
                }
            }
        }
    }
}

// Progress bar component
struct ProgressBar: View {
    var progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Greay bar
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 6)
                
                // Active  red bar
                Capsule()
                    .fill(Color.redTheme)
                    .frame(width: geo.size.width * CGFloat(progress), height: 6)
                    .shadow(color: Color.redTheme.opacity(0.6), radius: 6, x: 0, y: 2)
            }
        }
        .frame(height: 6)
        .padding(.horizontal, 24)
    }
}
