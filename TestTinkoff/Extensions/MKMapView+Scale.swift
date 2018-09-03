//
//  MKMapView+Scale.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 03.09.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import UIKit
import MapKit

extension MKMapView {
    
    func scaleMap(center: CLLocationCoordinate2D, zoom: Double) {
        let currentSpan = self.region.span
        let span = MKCoordinateSpan(latitudeDelta: currentSpan.latitudeDelta * zoom,
                                    longitudeDelta: currentSpan.longitudeDelta * zoom)
        let region = MKCoordinateRegion(center: center, span: span)
        self.setRegion(region, animated: true)
    }
    
}
