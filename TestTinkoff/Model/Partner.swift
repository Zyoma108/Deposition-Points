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
    let url: String
    let hasLocations: Bool
    let isMomentary: Bool
    let depositionDuration: String
    let limitations: String
    let pointType: String
    let description: String
    
}
