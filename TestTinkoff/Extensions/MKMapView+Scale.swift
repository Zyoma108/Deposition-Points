//
//  MKMapView+Scale.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 03.09.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import UIKit
import MapKit

private let defaultDelta: Double = 0.02

extension MKMapView {
    
    func scaleMap(zoom: Double) {
        let currentSpan = self.region.span
        let span = MKCoordinateSpan(latitudeDelta: currentSpan.latitudeDelta * zoom,
                                    longitudeDelta: currentSpan.longitudeDelta * zoom)
        let region = MKCoordinateRegion(center: self.region.center, span: span)
        self.setRegion(region, animated: true)
    }
    
    func setPosision(coordinate: CLLocationCoordinate2D) {
        let span: MKCoordinateSpan
        if self.region.span.latitudeDelta > defaultDelta || self.region.span.longitudeDelta > defaultDelta {
            span = MKCoordinateSpan(latitudeDelta: defaultDelta, longitudeDelta: defaultDelta)
        } else {
            span = self.region.span
        }
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.setRegion(region, animated: true)
    }
    
}
