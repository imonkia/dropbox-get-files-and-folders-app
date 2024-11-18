//
//  Environment.swift
//  SwiftyDropbox-Example
//
//  Created by Monica Auriemma on 10/24/24.
//

import Foundation

public enum Environment {
    enum Keys {
        static let appKey = "APP_KEY"
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("plist file not found")
        }
        return dict
    }()
    
    static let appKey: String = {
        guard let appKeyString = Environment.infoDictionary[Keys.appKey] as? String else {
            fatalError("App Key not set in plist")
        }
        return appKeyString
    }()
}
