//
//  PartnerInteractor.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 01.09.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import Foundation
import CoreData

class PartnerInteractor: Interactor {
    
    typealias EntityType = PartnerEntity
    typealias ServiceType = PartnersService
    
    var dataReceived: Bool = false
    
    var service: PartnersService { return PartnersService() }
    var fetchRequest: NSFetchRequest<PartnerEntity> { return PartnerEntity.fetchRequest() }
    
    func saveToStorage(_ data: [Decodable]) {
        let group = DispatchGroup()
        group.enter()
        DataStorage.shared.save({
            guard let partners = data as? [Partner] else { return }
            for partner in partners {
                guard let entity = DataStorage.shared.entity(type: PartnerEntity.self) else { continue }
                partner.save(to: entity)
            }
        }, {
            group.leave()
        })
        group.wait()
    }
    
}
