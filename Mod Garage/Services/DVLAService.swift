//
//  DVLAService.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 15/11/2025.
//

import Foundation

struct DVLAService {
    
    private let apiKey = Bundle.main.dvlaApiKey
    
    func fetchVehicle(for registration: String) async throws -> DVLAResponseModel{
        
        let url = URL(string: "https://driver-vehicle-licensing.api.gov.uk/vehicle-enquiry/v1/vehicles")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["registrationNumber": registration.uppercased()]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        //  Check status code as safecheck
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode != 200 {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode(DVLAResponseModel.self, from: data)
        return decoded
    }
}
