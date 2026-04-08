//
//  AuthUnitTests.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 15/11/2025.
//

import XCTest
@testable import Mod_Garage

@MainActor
final class UnitTests: XCTestCase {

    var signUpVM: SignUpViewModel!
    var loginVM: LoginViewModel!
    var forgotVM: ForgotPasswordViewModel!
    var addModVM: AddModificationViewModel!
    var addFuelLogVM: AddFuelLogViewModel!

    override func setUp() {
        signUpVM = SignUpViewModel()
        loginVM = LoginViewModel()
        forgotVM = ForgotPasswordViewModel()
        addModVM = AddModificationViewModel()
        addFuelLogVM = AddFuelLogViewModel()
    }
    
    func test_SignUp_Valid() {
        // 1. Arrange
        signUpVM.name = "Test User"
        signUpVM.email = "test@email.com"
        signUpVM.password = "test1234!"

        // 2. Act
        let isValid = signUpVM.isFormValid()
        
        // 3. Assert
        XCTAssertTrue(isValid)
    }
    
    func test_SignUp_EmptyField() {
        // 1. Arrange
        signUpVM.name = ""
        signUpVM.email = "test@email.com"
        signUpVM.password = "test1234!"

        // 2. Act
        let isValid = signUpVM.isFormValid()

        // 3. Assert
        XCTAssertFalse(isValid)
        XCTAssertEqual(signUpVM.signUpError, "Please fill in all fields")
    }
    
    func test_SignUp_InvalidEmail() {
        // 1. Arrange
        signUpVM.name = "Test User"
        signUpVM.email = "testemail.com"
        signUpVM.password = "test1234!"

        // 2. Act
        let isValid = signUpVM.isFormValid()

        // 3. Assert
        XCTAssertFalse(isValid)
        XCTAssertEqual(signUpVM.signUpError, "Please enter a valid email address")
    }
    
    func test_SignUp_NonEightCharacters() {
        // 1. Arrange
        signUpVM.name = "Test User"
        signUpVM.email = "test@email.com"
        signUpVM.password = "test123"

        // 2. Act
        let isValid = signUpVM.isFormValid()
        
        // 3. Assert
        XCTAssertFalse(isValid)
        XCTAssertEqual(signUpVM.signUpError, "Password must include at least 8 characters, a number and a special character")
    }
    
    func test_SignUp_MissingNumber() {
        // 1. Arrange
        signUpVM.name = "Test User"
        signUpVM.email = "test@email.com"
        signUpVM.password = "test!"

        // 2. Act
        let isValid = signUpVM.isFormValid()

        // 3. Assert
        XCTAssertFalse(isValid)
        XCTAssertEqual(signUpVM.signUpError, "Password must include at least 8 characters, a number and a special character")
    }
    
    func test_SignUp_MissingSpecialChar() {
        // 1. Arrange
        signUpVM.name = "Test User"
        signUpVM.email = "missingnum@email.com"
        signUpVM.password = "test1234"

        // 2. Act
        let isValid = signUpVM.isFormValid()

        // 3. Assert
        XCTAssertFalse(isValid)
        XCTAssertEqual(signUpVM.signUpError, "Password must include at least 8 characters, a number and a special character")
    }
    
    func test_Login_Valid() {
        // 1. Arrange
        loginVM.email = "test@email.com"
        loginVM.password = "test1234!"

        // 2. Act
        let isValid = loginVM.isFormValid()
        
        // 3. Assert
        XCTAssertTrue(isValid)
    }
    
    func test_Login_EmptyField() {
        // 1. Arrange
        loginVM.email = ""
        loginVM.password = "test1234!"

        // 2. Act
        let isValid = loginVM.isFormValid()

        // 3. Assert
        XCTAssertFalse(isValid)
        XCTAssertEqual(loginVM.loginError, "Please fill in all fields")
    }
    
    func test_ForgotPassword_Valid() {
        // 1. Arrange
        forgotVM.email = "test@email.com"

        // 2. Act
        let isValid = forgotVM.isFormValid()

        // 3. Assert
        XCTAssertTrue(isValid)
        XCTAssertNil(forgotVM.errorMessage)
    }
    func test_ForgotPassword_Invalid() {
        // 1. Arrange
        forgotVM.email = ""

        // 2. Act
        let isValid = forgotVM.isFormValid()

        // 3. Assert
        XCTAssertFalse(isValid)
        XCTAssertEqual(forgotVM.errorMessage, "Please enter your email address")
    }
    
    func test_VehicleCreation() {
        // 1. Arrange
        let id = UUID().uuidString
        let userId = "testUser123"
        let registration = "AB12CDE"
        let make = "Volkswagen"
        let model = "Polo"
        let year = 2016
        let colour = "Silver"
        let fuelType = "Petrol"
        let now = Date()

        // 2. Act
        let vehicle = VehicleModel(
            id: id,
            userId: userId,
            registration: registration,
            make: make,
            model: model,
            year: year,
            colour: colour,
            fuelType: fuelType,
            motExpiryDate: nil,
            motStatus: nil,
            taxExpiryDate: nil,
            taxStatus: nil,
            imageURL: nil,
            isPrimary: true,
            createdAt: now
        )

        // 3. Assert
        XCTAssertEqual(vehicle.id, id)
        XCTAssertEqual(vehicle.userId, userId)
        XCTAssertEqual(vehicle.registration, registration)
        XCTAssertEqual(vehicle.make, make)
        XCTAssertEqual(vehicle.model, model)
        XCTAssertEqual(vehicle.year, year)
        XCTAssertEqual(vehicle.colour, colour)
        XCTAssertEqual(vehicle.fuelType, fuelType)
        XCTAssertTrue(vehicle.isPrimary)
        XCTAssertEqual(vehicle.createdAt, now)
    }
    
    func test_ModValid() async {
        // 1. Arrange
        addModVM.modName = "Straight Pipe"
        addModVM.modType = "Exhaust"
        addModVM.modCost = 100.00
        addModVM.modDesc = "Deleted both resonator and backbox"
        
        // 2. Act
        let isValid = addModVM.isFormValid()
        
        // 3. Assert
        XCTAssertTrue(isValid)
    }
    
    func test_ModEmpty() {
        // 1. Arrange
        addModVM.modName = ""
        addModVM.modType = "Exhaust"
        addModVM.modCost = 100.00
        addModVM.modDesc = "Deleted both resonator and backbox"
        
        // 2. Act
        let isValid = addModVM.isFormValid()
        
        // 3. Assert
        XCTAssertFalse(isValid)
        XCTAssertEqual(addModVM.errorMessage, "Please fill in all fields")
    }
    
    func test_ModLongName() {
        // 1. Arrange
        addModVM.modName = "This is a name that is going to be longer than the character limit"
        addModVM.modType = "Exhaust"
        addModVM.modCost = 100.00
        addModVM.modDesc = "Deleted both resonator and backbox"
        
        // 2. Act
        let isValid = addModVM.isFormValid()
        
        // 3. Assert
        XCTAssertFalse(isValid)
        XCTAssertEqual(addModVM.errorMessage, "Please enter a shorter name")
    }

    func test_FuelLogValid() async {
        // 1. Arrange
        addFuelLogVM.location = "Shell Station"
        addFuelLogVM.cost = 60.00
        addFuelLogVM.litres = 48.00
        addFuelLogVM.mileage = 52000
        
        // 2. Act
        await addFuelLogVM.confirmFuelLog()
        
        // 3. Assert
        XCTAssertEqual(addFuelLogVM.savedLog?.location, "Shell Station" )
        XCTAssertEqual(addFuelLogVM.savedLog?.cost, 60.00 )
        XCTAssertEqual(addFuelLogVM.savedLog?.litres, 48.00 )
        XCTAssertEqual(addFuelLogVM.savedLog?.mileage, 52000 )
        XCTAssertEqual(addFuelLogVM.savedLog?.pricePerLitre,  60.00 / 48.00 )
        XCTAssertEqual(addFuelLogVM.savedLog?.mpg, 0.00 )
    }
    
    func test_FuelLogEmpty() {
        // 1. Arrange
        addFuelLogVM.location = ""
        addFuelLogVM.cost = 60.00
        addFuelLogVM.litres = 48.00
        addFuelLogVM.mileage = 52000
        
        // 2. Act
        let isValid = addFuelLogVM.isFormValid()
        
        // 3. Assert
        XCTAssertFalse(isValid)
        XCTAssertEqual(addFuelLogVM.errorMessage, "Please fill in all fields")
    }
    
    func test_FuelLogLongLocation() {
        // 1. Arrange
        addFuelLogVM.location = "This is a location too long to save"
        addFuelLogVM.cost = 60.00
        addFuelLogVM.litres = 48.00
        addFuelLogVM.mileage = 52000
        
        // 2. Act
        let isValid = addFuelLogVM.isFormValid()
        
        // 3. Assert
        XCTAssertFalse(isValid)
        XCTAssertEqual(addFuelLogVM.errorMessage, "Please entar a shorter name for the location")
    }
}

