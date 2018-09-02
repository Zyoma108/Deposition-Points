//
//  Interactor.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 02.09.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import Foundation
import CoreData

enum InteractorResult<T: NSManagedObject> {
    case success(result: [T])
    case failure(error: Error)
}

protocol Interactor: class {
    
    associatedtype EntityType: NSManagedObject
    associatedtype ServiceType: Service
    
    typealias InteractorCompletion = (_ result: InteractorResult<EntityType>) -> Void
    
    var service: ServiceType { get }
    var fetchRequest: NSFetchRequest<EntityType> { get }

    func saveToStorage(_ data: [Decodable])
    
}

extension Interactor {
    
    func requestData(completionQueue: DispatchQueue, _ completion: @escaping InteractorCompletion) {
        let workQueue = DispatchQueue.global(qos: .userInteractive)
        workQueue.async { [weak self] in
            self?.removeOldEntities()
            
            if let error = self?.loadFromNetwork() {
                completionQueue.async {
                    completion(.failure(error: error))
                }
            }
            
            guard let data = self?.loadFromStorage() else { return }
            completionQueue.async {
                completion(.success(result: data))
            }
        }
    }
    
    func loadFromNetwork() -> Error? {
        let group = DispatchGroup()
        var networkError: Error?
        
        group.enter()
        service.receive { [weak self] result in
            switch result {
            case .success(let result):
                self?.saveToStorage(result)
            case .failure(let error):
                networkError = error
            }
            group.leave()
        }
        group.wait()
        return networkError
    }
    
    func loadFromStorage() -> [EntityType] {
        let group = DispatchGroup()
        var entities = [EntityType]()
        
        group.enter()
        DataStorage.shared.fetch(request: fetchRequest) { result in
            entities = result
            group.leave()
        }
        group.wait()
        return entities
    }
    
    func removeOldEntities() {
        let group = DispatchGroup()
        
        group.enter()
        DataStorage.shared.remove(request: fetchRequest) {
            group.leave()
        }
        group.wait()
    }
}
