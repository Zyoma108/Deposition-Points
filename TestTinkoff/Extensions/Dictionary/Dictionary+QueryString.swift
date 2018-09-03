//
//  Dictionary+QueryString.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 31.08.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import Foundation

extension Dictionary where Key == String, Value == String {
    
    var queryString: String {
        var resultString = ""
        for (key, value) in self {
            resultString += "\(key)=\(value)&"
        }
        resultString.removeLast()
        return resultString
    }
}
