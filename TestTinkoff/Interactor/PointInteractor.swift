//
//  PointInteractor.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 01.09.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import Foundation

enum PointResult {
    case success(points: [PointEntity])
    case failure(error: Error)
}

class PointInteractor {
    
    func requestPoints() -> PointResult {
        removeOldEntities()
        
        if let error = loadFromNetwork() {
            return .failure(error: error)
        }
        
        return .success(points: getPoints())
    }
    
    func getPoints() -> [PointEntity] {
        let group = DispatchGroup()
        var entities = [PointEntity]()
        
        group.enter()
        DataStorage.shared.fetch(request: PointEntity.fetchRequest()) { result in
            entities = result
            group.leave()
        }
        group.wait()
        return entities
    }
    
    private func loadFromNetwork() -> Error? {
        let group = DispatchGroup()
        let service = PointService(latitude: 55.755786, longitude: 37.617633, radius: 1000)
        var networkError: Error?
        
        group.enter()
        service.receive { [weak self] result in
            switch result {
            case .success(let result):
                self?.savePoints(result)
            case .failure(let error):
                networkError = error
            }
            group.leave()
        }
        group.wait()
        return networkError
    }
    
    private func savePoints(_ points: [Point]) {
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
    
    private func removeOldEntities() {
        let group = DispatchGroup()
        
        group.enter()
        DataStorage.shared.remove(request: PointEntity.fetchRequest()) {
            group.leave()
        }
        group.wait()
    }
    
}
