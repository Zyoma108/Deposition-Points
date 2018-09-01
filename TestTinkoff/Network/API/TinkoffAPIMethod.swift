//
//  TinkoffAPIMethod.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 31.08.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import Foundation

enum TinkoffAPIMethod: APIMethod {
    
    case depositionPartners(accountType: String)
    case depositionPoints(latitude: Double, longitude: Double, radius: Int)

    var path: String {
        switch self {
        case .depositionPartners:
            return "/deposition_partners"
        case .depositionPoints:
            return "/deposition_points"
        }
    }
    
    var parameters: [String: String] {
        var result = [String: String]()
        switch self {
        case .depositionPartners(let accountType):
            result["accountType"] = accountType
        case .depositionPoints(let latitude, let longitude, let radius):
            result["latitude"] = String(latitude)
            result["longitude"] = String(longitude)
            result["radius"] = String(radius)
        }
        return result
    }
    
}
