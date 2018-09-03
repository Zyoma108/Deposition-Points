//
//  CLLocationCoordinate2D+Location.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 03.09.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
    
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
}
