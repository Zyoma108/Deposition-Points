//
//  PartnerInteractor.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 01.09.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import Foundation

class PartnerInteractor {
    
    func requestPartners() -> [PartnerEntity] {
        let group = DispatchGroup()
        
        // remove old entities
        group.enter()
        DataStorage.shared.remove(request: PartnerEntity.fetchRequest()) {
            group.leave()
        }
        group.wait()
        
        // make network request
        group.enter()
        let service = PartnersService()
        service.receive { result in
            switch result {
            case .success(let result):
                for partner in result {
                    guard let entity = DataStorage.shared.entity(type: PartnerEntity.self) else { continue }
                    partner.save(to: entity)
                }
                DataStorage.shared.save()
            case .failure(let error):
                print(error)
            }
            group.leave()
        }
        group.wait()
        
        return getPartners()
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
    
}
