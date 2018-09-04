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
    
    var gateway: PointGateway?
    let partnerGateway = PartnerGateway()
    
    var annotationsUpdated: ((_ annotations: [MKAnnotation]) -> Void)?
    var onError: ((_ error: Error) -> Void)?
    var loadingChanged: ((_ isLoading: Bool) -> Void)?
    
    func needUpdatePoints(latitude: Double, longitude: Double, radius: Double) {
        loadingChanged?(true)
        gateway = PointGateway(latitude: latitude, longitude: longitude, radius: Int(radius))
        if !partnerGateway.dataReceived {
            requestPartners()
        } else {
            requestPoints()
        }
    }
    
    private func requestPoints() {
        gateway?.requestData(completionQueue: DispatchQueue.main, force: true) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let result):
                let annotations = result.map { point -> MKAnnotation in
                    let imageUrl: String?
                    if let pictureName = point.partner?.picture {
                        imageUrl = Constants.fileDomain + "/icons/deposition-partners-v3/xxhdpi/" + pictureName
                    } else {
                        imageUrl = nil
                    }
                    return DepositionPointAnnotation(latitude: point.latitude,
                                                     longitude: point.longitude,
                                                     imageUrl: imageUrl)
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
        partnerGateway.requestData(completionQueue: DispatchQueue.main, force: true) { [weak self] result in
            guard let `self` = self else { return }
            
            switch result {
            case .success(_):
                print("Partners list successfully updated")
                self.partnerGateway.dataReceived = true
                self.requestPoints()
            case .failure(let error):
                self.onError?(error)
                self.loadingChanged?(false)
            }
        }
    }
    
}
