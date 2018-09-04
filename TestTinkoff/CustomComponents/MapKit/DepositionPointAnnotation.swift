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
    let imageName: String?
    
    init(latitude: Double, longitude: Double, imageName: String?) {
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.imageName = imageName
    }
    
}
