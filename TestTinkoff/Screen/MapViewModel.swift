//
//  MapViewModel.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 02.09.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import Foundation
import CoreLocation

class MapViewModel {
    
    var currentLocation: CLLocation?
    var needSetCurrentLocation: Bool = false
    
    var interactor: PointInteractor?
    let partnerInteractor = PartnerInteractor()
    
    func requestPartners() {
        partnerInteractor.requestData(completionQueue: DispatchQueue.main, force: true) { result in
            print(result)
        }
    }
    
    func requestPoints(latitude: Double, longitude: Double, radius: Double) {
        print("Request points")
        interactor = PointInteractor(latitude: latitude, longitude: longitude, radius: Int(radius))
        interactor?.requestData(completionQueue: DispatchQueue.main, force: true) { result in
            switch result {
            case .success(let result):
                print("Received \(result.count) points")
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
}
