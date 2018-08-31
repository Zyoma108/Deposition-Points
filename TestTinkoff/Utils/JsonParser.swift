//
//  JsonParser.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 31.08.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import Foundation

class JsonParser {
    
    private init() {}
    
    static func getObjectWith(key: String, from data: Data) -> Any? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
            let dictionary = jsonObject as? [String: Any] else { return nil }
        
        return dictionary[key]
    }
    
    static func getStringWith(key: String, from data: Data) -> String? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
            let dictionary = jsonObject as? [String: Any] else { return nil }
        
        return dictionary[key] as? String
    }
    
    static func getData(from object: Any) -> Data? {
        return try? JSONSerialization.data(withJSONObject: object, options: [])
    }
    
}
