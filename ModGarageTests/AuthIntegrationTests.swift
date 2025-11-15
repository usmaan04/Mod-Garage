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
final class AuthIntegrationTests: XCTestCase {

    var signUpVM: SignUpViewModel!
    var logInVM: LoginViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        signUpVM = SignUpViewModel()
        logInVM = LoginViewModel()
        cancellables = []
    }

    override func tearDown() {
        try? Auth.auth().signOut()
        cancellables = nil
        signUpVM = nil
        logInVM = nil
    }

    // MARK: - Sign Up Integration Tests

    // Tests for invalid existing email
    func test_SignUp_ExistingEmail_WhenUsingRealFirebase() async throws {
        // 1. Arrange
        let expectation = expectation(description: "Firebase should return a weak password error")
        
        // Use a unique email each time to prevent "email already in use" errors
        let uniqueEmail = "test-user-\(UUID().uuidString)@example.com"

        signUpVM.name = "Integration Test User"
        signUpVM.email = "test@email.com"
        signUpVM.password = "test123"
        
        // Set up a listener for the error property
        signUpVM.$signUpError
            .dropFirst()
            .sink { errorMessage in
                // 3. Assert
                let expectedError = "Password must include at least 8 characters, a number and a special character."
                XCTAssertEqual(errorMessage, expectedError, "The error message was not correct for a weak password.")
                
                // Tell the test waiting is done
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // 2. Act
        signUpVM.register()

        // Wait for the expectation
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    // Tests for invalid email format
    func test_SignUp_InvalidEmailFormat_WhenUsingRealFirebase() async throws {
        // 1. Arrange
        let expectation = expectation(description: "Firebase should return a weak password error")
        
        // Use a unique email each time to prevent "email already in use" errors
        let uniqueEmail = "test-user-\(UUID().uuidString)@example.com"

        signUpVM.name = "Integration Test User"
        signUpVM.email = "testemail.com"
        signUpVM.password = "test123"
        
        // Set up a listener for the error property
        signUpVM.$signUpError
            .dropFirst()
            .sink { errorMessage in
                // 3. Assert
                let expectedError = "Password must include at least 8 characters, a number and a special character."
                XCTAssertEqual(errorMessage, expectedError, "The error message was not correct for a weak password.")
                
                // Tell the test waiting is done
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // 2. Act
        signUpVM.register()

        // Wait for the expectation
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    // Tests for invalid non 8 characters in password
    func test_SignUp_WeakPassword_NonEightCharacters_WhenUsingRealFirebase() async throws {
        // 1. Arrange
        let expectation = expectation(description: "Firebase should return a weak password error")
        
        // Use a unique email each time to prevent "email already in use" errors
        let uniqueEmail = "test-user-\(UUID().uuidString)@example.com"

        signUpVM.name = "Integration Test User"
        signUpVM.email = "testIntegration@email.com"
        signUpVM.password = "test123"
        
        // Set up a listener for the error property
        signUpVM.$signUpError
            .dropFirst()
            .sink { errorMessage in
                // 3. Assert
                let expectedError = "Password must include at least 8 characters, a number and a special character."
                XCTAssertEqual(errorMessage, expectedError, "The error message was not correct for a weak password.")
                
                // Tell the test waiting is done
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // 2. Act
        signUpVM.register()

        // Wait for the expectation to be fulfilled or time out after 10 seconds
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    // Tests for invalid missing number in password
    func test_SignUp_WeakPassword_MissingNumber_WhenUsingRealFirebase() async throws {
        // 1. Arrange
        let expectation = expectation(description: "Firebase should return a weak password error")
        
        // Use a unique email each time to prevent "email already in use" errors
        let uniqueEmail = "test-user-\(UUID().uuidString)@example.com"

        signUpVM.name = "Integration Test User"
        signUpVM.email = "testIntegration@email.com"
        signUpVM.password = "testPass!"
        
        // Set up a listener for the error property
        signUpVM.$signUpError
            .dropFirst()
            .sink { errorMessage in
                // 3. Assert
                let expectedError = "Password must include at least 8 characters, a number and a special character."
                XCTAssertEqual(errorMessage, expectedError, "The error message was not correct for a weak password.")
                
                // Tell the test waiting is done
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // 2. Act
        signUpVM.register()

        // Wait for the expectation
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    // Tests for invalid missing special character in password
    func test_SignUp_WeakPassword_MissingSpecialCharacter_WhenUsingRealFirebase() async throws {
        // 1. Arrange
        let expectation = expectation(description: "Firebase should return a weak password error")
        
        // Use a unique email each time to prevent "email already in use" errors
        let uniqueEmail = "test-user-\(UUID().uuidString)@example.com"

        signUpVM.name = "Integration Test User"
        signUpVM.email = "testIntegration@email.com"
        signUpVM.password = "test1234"
        
        // Set up a listener for the error property
        signUpVM.$signUpError
            .dropFirst()
            .sink { errorMessage in
                // 3. Assert
                let expectedError = "Password must include at least 8 characters, a number and a special character."
                XCTAssertEqual(errorMessage, expectedError, "The error message was not correct for a weak password.")
                
                // Tell the test waiting is done
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // 2. Act
        signUpVM.register()

        // Wait for the expectation
        await fulfillment(of: [expectation], timeout: 10.0)
    }

    // Tests for valid sign up
    func test_SignUp_Succeeds_WhenUsingValidDetails() async throws {
        // 1. Arrange
        let expectation = expectation(description: "Sign up should succeed and set isUserLoggedIn to true")
        
        // Use unique and valid details
        let uniqueEmail = "test-user-\(UUID().uuidString)@example.com"
        let validPassword = "test1234!"

        signUpVM.name = "Success Test User"
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
    }


    // MARK: - Login Integration Tests

    // Tests for invalid email
    func test_Login_InvalidEmailError_WhenUsingRealFirebase() async throws {
        // 1. Arrange
        let expectation = expectation(description: "Firebase should return an invalid email error")
        
        logInVM.email = "testemail.com"
        logInVM.password = "any-password"

        // Set up a listener for the loginError
        logInVM.$loginError
            .dropFirst()
            .sink { errorMessage in
                // 3. Assert
                let expectedError = "Invalid email or password. If you registered with Google, try the Google button below."
                XCTAssertEqual(errorMessage, expectedError, "The error message was not correct for an invalid email.")
                
                // Tell the test waiting is done
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // 2. Act
        logInVM.login()

        // Wait for the expectation
        await fulfillment(of: [expectation], timeout: 10.0)
    }

    // Tests for invalid password
    func test_Login_InvalidPasswordError_WhenUsingRealFirebase() async throws {
        // 1. Arrange
        let expectation = expectation(description: "Firebase should return a user not found error")
        
        // Use a new unique email
        let nonExistentEmail = "new-user-\(UUID().uuidString)@example.com"
        
        logInVM.email = nonExistentEmail
        logInVM.password = "test"

        // Set up a listener
        logInVM.$loginError
            .dropFirst()
            .sink { errorMessage in
                // 3. Assert
                let expectedError = "Invalid email or password. If you registered with Google, try the Google button below."
                XCTAssertEqual(errorMessage, expectedError, "The error message was not correct for a user not found error.")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // 2. Act
        logInVM.login()

        // Wait for the expectation
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    // Tests for valid log in
    func test_Login_Succeeds_WhenUsingValidDetails() async throws {
        // 1. Arrange
        let expectation = expectation(description: "Login should succeed and set isUserLoggedIn to true")
        
        // Set valid details
        let uniqueEmail = "login-test-\(UUID().uuidString)@example.com"
        let validPassword = "test1234!"

        // Create the user directly in Firebase
        try await Auth.auth().createUser(withEmail: uniqueEmail, password: validPassword)
        // Sign out immediately so login can be tested
        try Auth.auth().signOut()

        // Set view model with valid details
        logInVM.email = uniqueEmail
        logInVM.password = validPassword
        
        // Set up a listener for the isUserLoggedIn property
        logInVM.$isUserLoggedIn
            .dropFirst()
            .sink { isLoggedIn in
                // 3. Assert
                XCTAssertTrue(isLoggedIn, "isUserLoggedIn should be true after successful login")
                
                // Tell the test waiting is done
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // 2. Act
        logInVM.login()

        // Wait for the expectation
        await fulfillment(of: [expectation], timeout: 10.0)
    }
}

