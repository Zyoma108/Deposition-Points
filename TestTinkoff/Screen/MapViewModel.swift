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
    
    private let processQueue = DispatchQueue.global(qos: .userInteractive)
    private let mainQueue = DispatchQueue.main
    private var displayAnnotations = [DepositionPointAnnotation]()
    
    var currentLocation: CLLocation?
    var needSetCurrentLocation: Bool = false
    
    var gateway: PointGateway?
    let partnerGateway = PartnerGateway()
    
    var annotationsUpdated: ((_ new: [MKAnnotation], _ toRemove: [MKAnnotation]) -> Void)?
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
        gateway?.requestData(completionQueue: mainQueue, force: true) { [weak self] result in
            guard let `self` = self else { return }
            
            switch result {
            case .success(let result):
                self.prepareAnnotations(points: result)
            case .failure(let error):
                self.loadingChanged?(false)
                self.onError?(error)
            }
        }
    }
    
    private func prepareAnnotations(points: [PointEntity]) {
        processQueue.async { [weak self] in
            guard let `self` = self else { return }
            
            let receivedAnnotations = points.compactMap { point -> DepositionPointAnnotation? in
                guard let id = point.externalId else { return nil }
                
                let imageUrl: String?
                if let pictureName = point.partner?.picture {
                    imageUrl = Constants.fileDomain + "/icons/deposition-partners-v3/xxhdpi/" + pictureName
                } else {
                    imageUrl = nil
                }
                
                return DepositionPointAnnotation(id: id,
                                                 latitude: point.latitude,
                                                 longitude: point.longitude,
                                                 imageUrl: imageUrl)
            }
            
            var new = [DepositionPointAnnotation]()
            var toRemove = [DepositionPointAnnotation]()
            
            toRemove = self.displayAnnotations.filter({ displayAnnotation in
                return receivedAnnotations.first(where: { $0.id == displayAnnotation.id }) == nil
            })
            
            new = receivedAnnotations.filter({ receivedAnnotation in
                return self.displayAnnotations.first(where: { $0.id == receivedAnnotation.id }) == nil
            })
            self.displayAnnotations = receivedAnnotations
            
            self.mainQueue.async { [weak self] in
                self?.loadingChanged?(false)
                self?.annotationsUpdated?(new, toRemove)
            }
        }
    }
    
    private func requestPartners() {
        partnerGateway.requestData(completionQueue: mainQueue, force: true) { [weak self] result in
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
