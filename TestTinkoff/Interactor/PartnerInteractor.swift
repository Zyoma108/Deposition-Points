//
//  PartnerInteractor.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 01.09.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import Foundation

enum PartnerResult {
    case success(partners: [PartnerEntity])
    case failure(error: Error)
}

class PartnerInteractor {
    
    func requestPartners() -> PartnerResult {
        removeOldEntities()
        
        if let error = loadFromNetwork() {
            return .failure(error: error)
        }
        
        return .success(partners: getPartners())
    }
    
    func getPartners() -> [PartnerEntity] {
        let group = DispatchGroup()
        var entities = [PartnerEntity]()
        
        group.enter()
        DataStorage.shared.fetch(request: PartnerEntity.fetchRequest()) { result in
            entities = result
            group.leave()
        }
        group.wait()
        return entities
    }
    
    private func loadFromNetwork() -> Error? {
        let group = DispatchGroup()
        let service = PartnersService()
        var networkError: Error?
        
        group.enter()
        service.receive { [weak self] result in
            switch result {
            case .success(let result):
                self?.savePartners(result)
            case .failure(let error):
                networkError = error
            }
            group.leave()
        }
        group.wait()
        return networkError
    }
    
    private func savePartners(_ partners: [Partner]) {
        for partner in partners {
            guard let entity = DataStorage.shared.entity(type: PartnerEntity.self) else { continue }
            partner.save(to: entity)
        }
        DataStorage.shared.save()
    }
    
    private func removeOldEntities() {
        let group = DispatchGroup()
        
        group.enter()
        DataStorage.shared.remove(request: PartnerEntity.fetchRequest()) {
            group.leave()
        }
        group.wait()
    }
}
