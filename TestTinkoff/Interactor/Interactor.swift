//
//  Interactor.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 31.08.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import Foundation

enum InteractorResult<T> {
    
    case failure(error: Error)
    case success(result: T)
    
}

protocol Interactor {
    
    associatedtype T: Decodable
    
    var request: Request { get }
    
}

extension Interactor {
    
    func receive(_ completion: @escaping ((_ result: InteractorResult<T>) -> Void)) {
        request.send { result in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let result = try decoder.decode(T.self, from: data)
                    completion(.success(result: result))
                } catch {
                    completion(.failure(error: error))
                }
            case .failure(let error):
                completion(.failure(error: error))
            }
        }
    }
    
}
