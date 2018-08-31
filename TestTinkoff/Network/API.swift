//
//  API.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 31.08.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import Foundation

let api = API()

class API {
    
    fileprivate init() {}
    
    private let domain = Constants.domain
    private let apiVersion = Constants.apiVersion
    
    func request(_ method: APIMethod) -> Request {
        return GetRequest(domain: domain, path: apiVersion + method.path, parameters: method.parameters)
    }
    
}
