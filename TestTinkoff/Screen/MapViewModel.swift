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
    var onError: ((_ error: Error) -> Void)?
    var loadingChanged: ((_ isLoading: Bool) -> Void)?
    
    func needUpdatePoints(latitude: Double, longitude: Double, radius: Double) {
        loadingChanged?(true)
        interactor = PointInteractor(latitude: latitude, longitude: longitude, radius: Int(radius))
        if !partnerInteractor.dataReceived {
            requestPartners()
        } else {
            requestPoints()
        }
    }
    
    private func requestPoints() {
        interactor?.requestData(completionQueue: DispatchQueue.main, force: true) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let result):
                let annotations = result.map { point -> MKPointAnnotation in
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
                    return annotation
                }
                self.annotationsUpdated?(annotations)
                self.loadingChanged?(false)
            case .failure(let error):
                self.onError?(error)
                self.loadingChanged?(false)
            }
        }
    }
    
    private func requestPartners() {
        partnerInteractor.requestData(completionQueue: DispatchQueue.main, force: true) { [weak self] result in
            guard let `self` = self else { return }
            
            switch result {
            case .success(_):
                print("Partners list successfully updated")
                self.partnerInteractor.dataReceived = true
                self.requestPoints()
            case .failure(let error):
                self.onError?(error)
                self.loadingChanged?(false)
            }
        }
    }
    
}
