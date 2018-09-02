//
//  PointInteractor.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 01.09.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import Foundation
import CoreData

class PointInteractor: Interactor {
    
    typealias EntityType = PointEntity
    typealias ServiceType = PointService
    
    var service: PointService { return PointService(latitude: 55.755786, longitude: 37.617633, radius: 1000) }
    var fetchRequest: NSFetchRequest<PointEntity> { return PointEntity.fetchRequest() }
    
    func saveToStorage(_ data: [Decodable]) {
        guard let points = data as? [Point] else { return }
        let group = DispatchGroup()
        var partners = [PartnerEntity]()
        
        group.enter()
        DataStorage.shared.fetch(request: PartnerEntity.fetchRequest()) { result in
            partners = result
            group.leave()
        }
        group.wait()
        
        points.forEach { point in
            guard let entity = DataStorage.shared.entity(type: PointEntity.self),
                let partner = partners.first(where: { $0.id! == point.partnerName }) else { return }
            
            point.save(to: entity)
            entity.partner = partner
        }
        
        DataStorage.shared.save()
    }

}
