//
//  PointInteractor.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 31.08.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import Foundation

class PointInteractor: Interactor {
    
    typealias T = [Point]
    
    private let latitude: Double
    private let longitude: Double
    private let radius: Int
    
    init(latitude: Double, longitude: Double, radius: Int) {
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
    }
    
    var request: Request {
        let method = TinkoffAPIMethod.depositionPoints(latitude: latitude, longitude: longitude, radius: radius)
        return api.request(method)
    }
    
}
