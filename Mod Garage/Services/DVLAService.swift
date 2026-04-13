//
//  DVLAService.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 15/11/2025.
//

import Foundation

// Handles the connection to the DVLA database
struct DVLAService {
    
    // Retrieves secret API key stored in the project settings
    private let apiKey = Bundle.main.dvlaApiKey
    
    // Sends a registration plate to the DVLA and waits for the vehicle's details
    func fetchVehicle(for registration: String) async throws -> DVLAResponseModel{
        
        // Web address for the VES
        let url = URL(string: "https://driver-vehicle-licensing.api.gov.uk/vehicle-enquiry/v1/vehicles")!
        
        // Prepaere request to be sent over the internet
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Add headers to prove authentication with API key and JSON data format
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Format registration plate so DVLA can understand it
        let body = ["registrationNumber": registration.uppercased()]
        request.httpBody = try JSONEncoder().encode(body)
        
        // Send request and wait for data to come back
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check if DVLA respomnds successfully or show an error
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode != 200 {
            throw URLError(.badServerResponse)
        }
        
        // Map the JSON response to the DVLAResponseModel
        let decoded = try JSONDecoder().decode(DVLAResponseModel.self, from: data)
        
        // Return vehicle back to app
        return decoded
    }
}
