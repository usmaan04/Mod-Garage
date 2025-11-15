import Foundation

extension Bundle {
    
    /**
     A helper to safely read a key from the Info.plist
     
     This will crash the app if the key is missing, which is what we want
     during development, as it alerts us that setup is wrong.
     */
    func infoValue<T>(for key: String) -> T {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? T else {
            fatalError("Could not find Info.plist key '\(key)'. Did you add it to the plist and link the xcconfig?")
        }
        return value
    }
    
    // A specific computed property for your API key
    var dvlaApiKey: String {
        return infoValue(for: "DVLA_API_KEY")
    }
}


