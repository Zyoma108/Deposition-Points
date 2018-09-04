//
//  MapViewModel.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 02.09.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import Foundation
import MapKit

class MapViewModel {
    
    var currentLocation: CLLocation?
    var needSetCurrentLocation: Bool = false
    
    var interactor: PointInteractor?
    let partnerInteractor = PartnerInteractor()
    
    var annotationsUpdated: ((_ annotations: [MKAnnotation]) -> Void)?
    
    func requestPartners() {
        print("Request partners")
        partnerInteractor.requestData(completionQueue: DispatchQueue.main, force: true) { result in
            switch result {
            case .success(let result):
                print("Received \(result.count) partners")
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func requestPoints(latitude: Double, longitude: Double, radius: Double) {
        print("Request points")
        interactor = PointInteractor(latitude: latitude, longitude: longitude, radius: Int(radius))
        interactor?.requestData(completionQueue: DispatchQueue.main, force: true) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let result):
                print("Received \(result.count) points")
                let annotations = result.map { point -> MKPointAnnotation in
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
                    return annotation
                }
                self.annotationsUpdated?(annotations)
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
}
