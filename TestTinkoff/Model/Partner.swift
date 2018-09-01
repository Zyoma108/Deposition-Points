//
//  Partner.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 31.08.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import Foundation

struct Partner: Decodable {
    
    let id: String
    let name: String
    let picture: String
    let pointType: String
    
}

extension Partner {
    
    func save(to entity: PartnerEntity) {
        entity.id = self.id
        entity.name = self.name
        entity.picture = self.picture
        entity.pointType = self.pointType
    }
    
}
