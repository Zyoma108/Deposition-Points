//
//  Point.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 31.08.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import Foundation

struct Location: Decodable {
    
    let latitude: Double
    let longitude: Double
    
}

struct Point: Decodable {
    
    let externalId: String
    let partnerName: String
    let location: Location
    let addressInfo: String?
    let fullAddress: String?

}

extension Point {
    
    func save(to entity: PointEntity) {
        entity.externalId = self.externalId
        entity.latitude = self.location.latitude
        entity.longitude = self.location.longitude
        entity.addressInfo = self.addressInfo
        entity.fullAddress = self.fullAddress
    }
    
}

