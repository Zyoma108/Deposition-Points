//
//  ReadHeadRequest.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 05.09.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import Foundation

class ReadHeadRequest: Request {
    
    let urlString: String

    init(url: String) {
        self.urlString = url
    }
    
    func send(_ completion: @escaping RequestCompletion) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
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
    
}
