//
//  Service.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 31.08.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import Foundation

enum ServiceResult<T> {
    
    case failure(error: Error)
    case success(result: [T])
    
}

protocol Service {
    
    associatedtype T: Decodable
    
    var request: Request { get }
    
}

extension Service {
    
    func receive(_ completion: @escaping ((_ result: ServiceResult<T>) -> Void)) {
        request.send { result in
            switch result {
            case .success(let data):
                if let errorMessage = JsonParser.getStringWith(key: "errorMessage", from: data) {
                    completion(.failure(error: StringError(description: errorMessage)))
                } else {
                    if let payload = JsonParser.getObjectWith(key: "payload", from: data),
                        let payloadData = JsonParser.getData(from: payload) {
                        let decoder = JSONDecoder()
                        do {
                            let result = try decoder.decode([T].self, from: payloadData)
                            completion(.success(result: result))
                        } catch {
                            completion(.failure(error: error))
                        }
                    } else {
                        completion(.failure(error: StringError(description: "Unable to parse payload value")))
                    }
                }
            case .failure(let error):
                completion(.failure(error: error))
            }
        }
    }
    
}
