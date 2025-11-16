//
//  AuthUnitTests.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 15/11/2025.
//

import XCTest
@testable import Mod_Garage

@MainActor
final class AuthUnitTests: XCTestCase {

    var signUpVM: SignUpViewModel!
    var logInVM: LoginViewModel!

    override func setUp() {
        signUpVM = SignUpViewModel()
        logInVM = LoginViewModel()
    }
    
    func test_SignUp_FillFieldError_WhenEmptyFields() {
        // 1. Arrange
        signUpVM.name = ""
        signUpVM.email = ""
        signUpVM.password = ""

        // 2. Act
        signUpVM.register()
        
        // 3. Assert
        XCTAssertEqual(signUpVM.signUpError, "Please fill in all fields")
        XCTAssertFalse(signUpVM.isLoading)
    }
    
    func test_SignUp_InvalidEmailFormat() {
        // 1. Arrange
        signUpVM.name = "Test User"
        signUpVM.email = "invalidemail.com"
        signUpVM.password = "test1234!"

        // 2. Act
        signUpVM.register()
        
        // 3. Assert
        XCTAssertEqual(signUpVM.signUpError, "Please enter a valid email address")
        XCTAssertFalse(signUpVM.isLoading)
    }
    
    func test_SignUp_WeakPasswordError_NonEightCharacters() {
        // 1. Arrange
        signUpVM.name = "Test User"
        signUpVM.email = "noneight@email.com"
        signUpVM.password = "test1!"

        // 2. Act
        signUpVM.register()
        
        // 3. Assert
        XCTAssertEqual(signUpVM.signUpError, "Password must include at least 8 characters, a number and a special character")
        XCTAssertFalse(signUpVM.isLoading)
    }
    
    func test_SignUp_WeakPasswordError_MissingNumber() {
        // 1. Arrange
        signUpVM.name = "Test User"
        signUpVM.email = "missingnum@email.com"
        signUpVM.password = "testpass!"

        // 2. Act
        signUpVM.register()
        
        // 3. Assert
        XCTAssertEqual(signUpVM.signUpError, "Password must include at least 8 characters, a number and a special character")
        XCTAssertFalse(signUpVM.isLoading)
    }
    
    func test_SignUp_WeakPasswordError_MissingSpecialChar() {
        // 1. Arrange
        signUpVM.name = "Test User"
        signUpVM.email = "missingnum@email.com"
        signUpVM.password = "testpass1"

        // 2. Act
        signUpVM.register()
        
        // 3. Assert
        XCTAssertEqual(signUpVM.signUpError, "Password must include at least 8 characters, a number and a special character")
        XCTAssertFalse(signUpVM.isLoading)
    }
    
    func test_Login_FillFieldError_WhenEmptyFields() {
        // 1. Arrange
        logInVM.email = ""
        logInVM.password = ""
        
        // 2. Act
        logInVM.login()

        // 3. Assert
        XCTAssertEqual(logInVM.loginError, "Please fill in all fields")
        XCTAssertFalse(logInVM.isLoading)
    }
}


