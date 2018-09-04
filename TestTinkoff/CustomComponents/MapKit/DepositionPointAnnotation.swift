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
    
    let coordinate: CLLocationCoordinate2D
    let imageUrl: String?
    
    init(latitude: Double, longitude: Double, imageUrl: String?) {
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.imageUrl = imageUrl
    }
    
}
