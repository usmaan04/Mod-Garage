//
//  DVLAIntegrationTests.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 15/11/2025.
//


//
//  DVLAIntegrationTests.swift
//  ModGarageTests
//
//  Created by Usmaan Ahmed on 15/11/2025.
//

import XCTest
import Combine
@testable import Mod_Garage // Import your app module

@MainActor
final class DVLAIntegrationTests: XCTestCase {

    var viewModel: AddVehicleViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        viewModel = AddVehicleViewModel()
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        cancellables = nil
    }

    // Tests for an invalid registration
    func test_searchRegistration_invalidRegistration_setsErrorMessage_whenUsingRealAPI() async throws {
        
        // 1. Arrange
        let expectation = expectation(description: "Error message should be set from real API error")
        
        // A guraanteed invalid registration
        viewModel.registration = "X1X1X1X"
        
        // Listen for the errorMessage to change
        viewModel.$errorMessage
            .compactMap{$0}
            .sink { errorMessage in
                
                // 3. Assert
                let expectedError = "Could not find vehicle, Please check the registration"
                XCTAssertEqual(errorMessage, expectedError, "The real API error wasn't mapped correctly.")
                
                // Tell the test we are done
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // 2. Act
        viewModel.searchRegistration()

        // Wait for the expectation to be fulfilled
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    // Tests for an valid registration (from DVLA Documents)
    func test_searchRegistration_validRegistration_setsVehicleModel_whenUsingRealAPI() async throws {
        
        // 1. Arrange
        let expectation = expectation(description: "Vehicle should be set from real API success")
        
        // Use an official DVLA test registration number
        viewModel.registration = "UX14MED"
        
        // Listen for the dvlaVehicle property to change
        viewModel.$dvlaVehicle
            .compactMap { $0 }
            .sink { vehicle in
                
                // 3. Assert
                // Check that the returned data matches the expected test data from DVLA docs
                XCTAssertEqual(vehicle.registrationNumber, "UX14MED", "Registration number did not match.")
                XCTAssertEqual(vehicle.make, "SEAT", "Make did not match.")
                XCTAssertEqual(vehicle.colour, "GREY", "Colour did not match.")
                
                // Also assert that no error was set
                XCTAssertNil(self.viewModel.errorMessage, "Error message should be nil on success.")
                
                // Tell the test we are done
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // 2. Act
        viewModel.searchRegistration()

        // Wait
        await fulfillment(of: [expectation], timeout: 20.0)
    }

}



