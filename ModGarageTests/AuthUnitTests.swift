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
        
        // 3. Assert (Check the result)
        XCTAssertEqual(signUpVM.signUpError, "Please fill in all fields")
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


