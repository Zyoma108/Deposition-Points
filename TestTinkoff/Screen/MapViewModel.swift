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
    private var isLoading: Bool = false
    private var gateway: PointGateway?
    private let partnerGateway = PartnerGateway()
    
    var currentLocation: CLLocation?
    var locationReceivedFirstTime: Bool = true
    
    weak var delegate: MapViewModelDelegate!
    
    func needUpdatePoints(latitude: Double, longitude: Double, radius: Double) {
        isLoading = true
        delegate.loadingChanged(isLoading: isLoading)
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
                self.isLoading = false
                self.notifyAboutLoading()
                self.delegate.onError(error: error)
            }
        }
    }
    
    private func prepareAnnotations(points: [PointEntity]) {
        let displayAnnotations = delegate.currentAnnotation().compactMap({ $0 as? DepositionPointAnnotation })
        processQueue.async { [weak self] in
            guard let `self` = self else { return }
            
            let receivedAnnotations = points.compactMap { point -> DepositionPointAnnotation? in
                guard let id = point.externalId else { return nil }
                
                let imageUrl: String?
                if let pictureName = point.partner?.picture {
                    imageUrl = Constants.fileDomain + "/icons/deposition-partners-v3/\(self.imagesResolution)/" + pictureName
                } else {
                    imageUrl = nil
                }
                
                return DepositionPointAnnotation(id: id,
                                                 latitude: point.latitude,
                                                 longitude: point.longitude,
                                                 imageUrl: imageUrl,
                                                 pointName: point.partner?.name,
                                                 address: point.fullAddress)
            }
            
            var new = [DepositionPointAnnotation]()
            var toRemove = [DepositionPointAnnotation]()
            
            toRemove = displayAnnotations.filter({ displayAnnotation in
                return receivedAnnotations.first(where: { $0.id == displayAnnotation.id }) == nil
            })
            
            new = receivedAnnotations.filter({ receivedAnnotation in
                return displayAnnotations.first(where: { $0.id == receivedAnnotation.id }) == nil
            })

            self.mainQueue.async { [weak self] in
                self?.isLoading = false
                self?.notifyAboutLoading()
                self?.delegate.updateAnnotations(new: new, toRemove: toRemove)
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
                self.isLoading = false
                self.delegate.onError(error: error)
                self.notifyAboutLoading()
            }
        }
    }
    
    private func notifyAboutLoading() {
        delegate.loadingChanged(isLoading: isLoading)
    }
    
    private lazy var imagesResolution: String = {
        let resolution: String
        switch Int(UIScreen.main.scale) {
        case Int.min...1:
            resolution = "mdpi"
        case 2:
            resolution = "hdpi"
        default:
            resolution = "xhdpi"
        }
        return resolution
    }()
    
    var okTitle: String { return "Ок" }
    var errorTitle: String { return "Ошибка" }
    var settingsTitle: String { return "Настройки" }
    var cancelTitle: String { return "Отмена" }
    
    var locationPermissionTitle: String {
        return "Невозможно определить местоположение"
    }
    var locationPermissionMessage: String {
        return "Для отображения текущей позиции приложению необходимо дать доступ к геоданным в настройках"
    }
    
}

protocol MapViewModelDelegate: class {
    
    func currentAnnotation() -> [MKAnnotation]
    
    func updateAnnotations(new: [MKAnnotation], toRemove: [MKAnnotation])
    
    func onError(error: Error)
    
    func loadingChanged(isLoading: Bool)
    
}
