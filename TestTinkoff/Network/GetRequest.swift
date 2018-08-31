//
//  GetRequest.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 31.08.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import Foundation

class GetRequest: Request {
    
    let endpoint: String
    let parameters: [String: String]
    
    init(endpoint: String, parameters: [String: String]) {
        self.endpoint = endpoint
        self.parameters = parameters
    }
    
    func send(_ completion: @escaping RequestCompletion) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error: error))
            }
            if let data = data {
                completion(.success(data: data))
            }
        }
        task.resume()
    }
    
    private var urlString: String {
        var result = endpoint
        if !parameters.isEmpty {
            result += "?" + parameters.queryString
        }
        return result
    }
    
}
