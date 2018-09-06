//
//  DepositionPointAnnotation.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 04.09.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import UIKit
import MapKit

class DepositionPointAnnotation: NSObject, MKAnnotation {
    
    let id: String
    let coordinate: CLLocationCoordinate2D
    let imageUrl: String?
    let pointName: String?
    let address: String?
    
    init(id: String, latitude: Double, longitude: Double, imageUrl: String?, pointName: String?, address: String?) {
        self.id = id
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.imageUrl = imageUrl
        self.pointName = pointName
        self.address = address
    }
    
}
