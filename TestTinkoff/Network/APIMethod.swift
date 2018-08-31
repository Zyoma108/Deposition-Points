//
//  APIMethod.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 31.08.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import Foundation

protocol APIMethod {
    
    var path: String { get }
    var parameters: [String: String] { get }
    
}
