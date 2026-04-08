//
//  AuthIntegrationTests.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 15/11/2025.
//


import XCTest
import Combine
import FirebaseAuth
@testable import Mod_Garage

@MainActor
final class InvalidIntegrationTests: XCTestCase {

    var signUpVM: SignUpViewModel!
    var loginVM: LoginViewModel!
    var addVehicleVM: AddVehicleViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        signUpVM = SignUpViewModel()
        loginVM = LoginViewModel()
        addVehicleVM = AddVehicleViewModel()
        cancellables = []
    }

    override func tearDown() {
        try? Auth.auth().signOut()
        cancellables = nil
        signUpVM = nil
        loginVM = nil
        addVehicleVM = nil
    }

    // Tests for invalid existing email
    func test_SignUp_ExistingEmail() async throws {
        // 1. Arrange
        let expectation = expectation(description: "Firebase should return an existinga coount error.")
        
        signUpVM.name = "Test User"
        signUpVM.email = "test@email.com"
        signUpVM.password = "test1234!"
        
        // Set up a listener for the error property
        signUpVM.$signUpError
            .compactMap{$0}
            .sink { errorMessage in
                print("Actual error:", errorMessage)
                // 3. Assert
                let expectedError = "This email is already registered"
                XCTAssertEqual(errorMessage, expectedError, "The error message was not correct for an existing account.")
                
                // Tell the test waiting is done
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // 2. Act
        signUpVM.register()

        // Wait for the expectation
        await fulfillment(of: [expectation], timeout: 10.0)
    }

    // Tests for invalid email
    @MainActor
    func test_Login_InvalidCredentials() async throws {
        let expectation = expectation(description: "loginError should be set")

        loginVM.email = "test@email.com"
        loginVM.password = "wrongpassword"

        loginVM.$loginError
            .compactMap { $0 }
            .sink { errorMessage in
                // 3. Assert
                let expectedError = "Invalid email or password. If you registered with Google, try the Google button below."
                XCTAssertEqual(errorMessage, expectedError)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        loginVM.login()

        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    // Tests for an invalid registration
    func test_InvalidDVLA() async throws {
        
        // 1. Arrange
        let expectation = expectation(description: "Error message should be set from real API error")
        
        // Invalid registration
        addVehicleVM.registration = "X1X1X1X"
        
        // Listen for the errorMessage to change
        addVehicleVM.$errorMessage
            .compactMap{$0}
            .sink { errorMessage in
                
                // 3. Assert
                let expectedError = "Could not find vehicle. Please check the registration"
                XCTAssertEqual(errorMessage, expectedError, "The real API error wasn't mapped correctly.")
                
                // Tell the test we are done
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // 2. Act
        addVehicleVM.searchRegistration()

        // Wait for the expectation to be fulfilled
        await fulfillment(of: [expectation], timeout: 10.0)
    }
}

