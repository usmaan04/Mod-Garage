//
//  AddVehicleUnitTest.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 18/11/2025.
//

import XCTest
@testable import Mod_Garage

final class VehicleModelTests: XCTestCase {
    
    func testVehicleModelCreation() {
        
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
}
