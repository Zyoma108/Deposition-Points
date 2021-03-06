//
//  GetRequest.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 31.08.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import Foundation

class GetRequest: Request {

    let domain: String
    let path: String?
    let parameters: [String: String]?
    
    init(domain: String, path: String?, parameters: [String: String]?) {
        self.domain = domain
        self.path = path
        self.parameters = parameters
    }
    
    func send(_ completion: @escaping RequestCompletion) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        var request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let headers = (response as? HTTPURLResponse)?.allHeaderFields
            if let error = error {
                completion(.failure(error: error), headers)
            } else if let data = data {
                completion(.success(data: data), headers)
            } else {
                completion(.failure(error: StringError(description: "Unknown Error")), headers)
            }
        }
        task.resume()
    }
    
    private var urlString: String {
        var result = domain
        if let path = path {
            result += "/" + path
        }
        if let parameters = parameters,
            !parameters.isEmpty {
            result += "?" + parameters.queryString
        }
        return result
    }
    
}
