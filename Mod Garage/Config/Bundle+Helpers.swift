//
//  Bundle+Helpers.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 15/11/2025.
//

import Foundation

extension Bundle {
    
    // A helper to read a key from the Info.plist
    func infoValue<T>(for key: String) -> T {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? T else {
            fatalError("Could not find Info.plist key '\(key)'?")
        }
        return value
    }
    
    // A specific computed property for  API key
    var dvlaApiKey: String {
        return infoValue(for: "DVLA_API_KEY")
    }
}


