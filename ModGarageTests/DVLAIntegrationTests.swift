//
//  DVLAIntegrationTests.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 15/11/2025.
//

import XCTest
import Combine
import FirebaseAuth
import FirebaseFirestore
@testable import Mod_Garage

@MainActor
final class ValidIntegrationTests: XCTestCase {

    var signUpVM: SignUpViewModel!
    var loginVM: LoginViewModel!
    var forgotVM: ForgotPasswordViewModel!
    var addVehicleVM: AddVehicleViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        signUpVM = SignUpViewModel()
        loginVM = LoginViewModel()
        forgotVM = ForgotPasswordViewModel()
        addVehicleVM = AddVehicleViewModel()
        cancellables = []
    }

    override func tearDown() {
        signUpVM = nil
        addVehicleVM = nil
        cancellables = nil
    }
    
    // Tests for valid sign up
    func test_SignUp() async throws {
        // 1. Arrange
        let expectation = expectation(description: "Sign up should succeed and set isUserLoggedIn to true")
        
        // Use unique and valid details
        let uniqueEmail = "test-user-\(UUID().uuidString)@email.com"
        let validPassword = "test1234!"

        signUpVM.name = "Test User"
        signUpVM.email = uniqueEmail
        signUpVM.password = validPassword
        
        // Set up a listener for the isUserLoggedIn property
        signUpVM.$isUserLoggedIn
            .dropFirst()
            .sink { isLoggedIn in
                // 3. Assert
                XCTAssertTrue(isLoggedIn, "isUserLoggedIn should be true after successful registration")
                
                // Tell the test waiting is done
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // 2. Act
        signUpVM.register()

        // Wait for the expectation
        await fulfillment(of: [expectation], timeout: 10.0)
        
        // 4. Cleanup
        let user = Auth.auth().currentUser
        XCTAssertNotNil(user, "User should be logged in to then be deleted to clean up")
        
        try? await user?.delete()
    }
    
    // Tests for valid log in
    func test_Login() async throws {
        // 1. Arrange
        let expectation = expectation(description: "Login should succeed and set isUserLoggedIn to true")

        // Set view model with valid details
        loginVM.email = "test@email.com"
        loginVM.password = "test1234!"
        
        // Set up a listener for the isUserLoggedIn property
        loginVM.$isUserLoggedIn
            .dropFirst()
            .sink { isLoggedIn in
                // 3. Assert
                XCTAssertTrue(isLoggedIn, "isUserLoggedIn should be true after successful login")
                
                // Tell the test waiting is done
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // 2. Act
        loginVM.login()

        // Wait for the expectation
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    // Tests for a valid forgot password flow
    func test_ForgotPassword() async throws {
        // 1. Arrange
        let expectation = expectation(description: "Forgot password should send reset email and set alertMessage")
        
        forgotVM.email = "test@email.com"
        let trimmedEmail = forgotVM.email.trimmingCharacters(in: .whitespacesAndNewlines)

        // Observe alertMessage to confirm success
        forgotVM.$alertMessage
            .compactMap { $0 }
            .sink { message in
                // 3. Assert
                XCTAssertEqual(message, "If an account exists an email has been sent to \(trimmedEmail)", "Alert message was not set correctly.")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // 2. Act
        forgotVM.forgotPassword()
        // Wait for the expectation
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    // Tests for an valid registration
    func test_ValidDVLA() async throws {
        
        // 1. Arrange
        let expectation = expectation(description: "Vehicle should be set from real API success")
        
        // Use an official DVLA test registration number
        addVehicleVM.registration = "UX14MED"
        
        // Listen for the dvlaVehicle property to change
        addVehicleVM.$dvlaVehicle
            .compactMap { $0 }
            .sink { vehicle in
                
                // 3. Assert
                // Check that the returned data matches the expected test data from DVLA docs
                XCTAssertEqual(vehicle.registrationNumber, "UX14MED", "Registration number did not match.")
                XCTAssertEqual(vehicle.make, "SEAT", "Make did not match.")
                XCTAssertEqual(vehicle.colour, "GREY", "Colour did not match.")
                
                // Also assert that no error was set
                XCTAssertNil(self.addVehicleVM.errorMessage, "Error message should be nil on success.")
                
                // Tell the test we are done
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // 2. Act
        addVehicleVM.searchRegistration()

        // Wait
        await fulfillment(of: [expectation], timeout: 20.0)
    }
    
}

