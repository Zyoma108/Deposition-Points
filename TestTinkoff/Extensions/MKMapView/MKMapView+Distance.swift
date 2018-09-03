//
//  MKMapView+Distance.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 03.09.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    
    var visibleMapRadius: CLLocationDistance {
        let topLeftCoordinate = convert(CGPoint(x: 0, y: 0), toCoordinateFrom: self)
        let topLeftLocation = CLLocation(latitude: topLeftCoordinate.latitude,
                                         longitude: topLeftCoordinate.longitude)
        return centerCoordinate.location.distance(from: topLeftLocation)
    }
    
}
