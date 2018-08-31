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
    
    func request(_ method: APIMethod) {
        let request = GetRequest(domain: domain, path: apiVersion + method.path, parameters: method.parameters)
        request.send { result in
            switch result {
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            case .success(let data):
                print("Data: \(data)")
            }
        }
    }
    
}
