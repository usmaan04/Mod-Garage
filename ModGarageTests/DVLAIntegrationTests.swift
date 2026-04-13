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
    
    // Test the full flow of adding a vehicle
    func test_AddVehicle() async throws {
        let user = Auth.auth().currentUser
        XCTAssertNotNil(user)
        guard user != nil else { return }

        let addVM = addVehicleVM!
        let vehiclesVM = VehicleViewModel()

        // 1. Arrange
        addVM.registration = "AB12CDE"
        addVM.model = "Test"
        addVM.existingVehicleCount = 0

        let savedExpectation = expectation(description: "Vehicle saved")

        addVM.onVehicleReady = { vehicle in
            Task {
                await vehiclesVM.addVehicle(vehicle)
                savedExpectation.fulfill()
            }
        }

        addVM.searchRegistration()

        // wait until dvlaVehicle is loaded
        let dvlaLoaded = expectation(description: "DVLA loaded")
        var cancellables = Set<AnyCancellable>()
        addVM.$dvlaVehicle
            .dropFirst()
            .sink { vehicle in
                if vehicle != nil {
                    dvlaLoaded.fulfill()
                }
            }
            .store(in: &cancellables)

        // 2. Act
        await fulfillment(of: [dvlaLoaded], timeout: 10)

        await addVM.confirmVehicle()

        await fulfillment(of: [savedExpectation], timeout: 10)

        await vehiclesVM.loadVehicles()

        // 3. Assert
        XCTAssertTrue(vehiclesVM.vehicles.contains {
            $0.registration.uppercased() == "AB12CDE"
        })
    }
    
    func test_AddModification() async throws {
        let user = Auth.auth().currentUser
        XCTAssertNotNil(user, "A user must be signed in before running integration tests")
        guard let user else { return }

        let detailVM = VehicleDetailViewModel()
        let addModVM = AddModificationViewModel()
    
        let db = Firestore.firestore()

        addModVM.vehicleId = "C22C0029-AE0D-4985-9594-408543CD7A26"
        addModVM.modType = "Exhaust"
        addModVM.modName = "Catback"
        addModVM.modCost = 200.00
        addModVM.modDesc = "Stainless steel catback exhaust"

        let savedExpectation = expectation(description: "Modification should be added and loaded")

        detailVM.$modifications
            .dropFirst()
            .sink { modifications in
                if modifications.contains(where: {
                    $0.name == "Catback" &&
                    $0.type == "Exhaust" &&
                    $0.description == "Stainless steel catback exhaust"
                }) {
                    savedExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        addModVM.onModificationReady = { modification in
            Task {
                await detailVM.addModification(modification, vehicleId: "C22C0029-AE0D-4985-9594-408543CD7A26")
            }
        }

        await addModVM.confirmModification()

        await fulfillment(of: [savedExpectation], timeout: 20.0)

        let snapshot = try await db
            .collection("users")
            .document(user.uid)
            .collection("vehicles")
            .document("C22C0029-AE0D-4985-9594-408543CD7A26")
            .collection("modifications")
            .getDocuments()

        XCTAssertTrue(
            snapshot.documents.contains(where: { doc in
                let data = doc.data()
                return (data["name"] as? String) == "Catback" &&
                       (data["type"] as? String) == "Exhaust" &&
                       (data["description"] as? String) == "Stainless steel catback exhaust"
            }),
            "The modification document should exist in Firestore"
        )
    }
    
    func test_AddFuelLog() async throws {
        let user = Auth.auth().currentUser
        XCTAssertNotNil(user, "A user must be signed in before running integration tests")
        guard let user else { return }

        let vehicleId = "C22C0029-AE0D-4985-9594-408543CD7A26"

        let detailVM = VehicleDetailViewModel()
        let addFuelVM = AddFuelLogViewModel()
        
        let db = Firestore.firestore()

        addFuelVM.previousMileage = 10000
        addFuelVM.location = "Shell"
        addFuelVM.litres = 40
        addFuelVM.cost = 58.40
        addFuelVM.mileage = 10200

        let savedExpectation = expectation(description: "Fuel log should be added and loaded")

        detailVM.$fuelLogs
            .dropFirst()
            .sink { logs in
                if logs.contains(where: {
                    $0.location == "Shell" &&
                    $0.litres == 40 &&
                    $0.cost == 58.40 &&
                    $0.mileage == 10200
                }) {
                    savedExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        addFuelVM.onFuelLogReady = { fuelLog in
            Task {
                await detailVM.addFuelLog(fuelLog, vehicleId: vehicleId)
            }
        }

        await addFuelVM.confirmFuelLog()

        await fulfillment(of: [savedExpectation], timeout: 20.0)

        let snapshot = try await db
            .collection("users")
            .document(user.uid)
            .collection("vehicles")
            .document(vehicleId)
            .collection("fuelLogs")
            .getDocuments()

        XCTAssertTrue(
            snapshot.documents.contains(where: { doc in
                let data = doc.data()
                return (data["location"] as? String) == "Shell" &&
                       (data["litres"] as? Double) == 40 &&
                       (data["cost"] as? Double) == 58.40 &&
                       (data["mileage"] as? Int) == 10200
            }),
            "The fuel log document should exist in Firestore"
        )
    }
    
}

