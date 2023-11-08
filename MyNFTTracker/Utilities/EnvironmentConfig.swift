//
//  EnvironmentConfig.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/7/23.
//

import Foundation

public enum EnvironmentConfig {
    enum Keys: String {
        case alchemyAPIKey = "ALCHEMY_API_KEY"
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()
    
    static let alchemyAPIKey: String = {
        guard let value = EnvironmentConfig.infoDictionary[Keys.alchemyAPIKey.rawValue] as? String else {
            fatalError("Alchemy API key not set in plist for this environment")
        }
        
        return value
    }()

}
