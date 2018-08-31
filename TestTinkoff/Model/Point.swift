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
    
    let partnerName: String
    let location: Location
    let workHours: String?
    let phones: String?
    let addressInfo: String?
    let fullAddress: String?

}
