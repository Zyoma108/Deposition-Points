//
//  MapViewController.swift
//  TestTinkoff
//
//  Created by Roman Sentsov on 31.08.2018.
//  Copyright © 2018 Roman Sentsov. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    @IBOutlet private weak var mapView: MKMapView!
    private let locationManager = CLLocationManager()
    private let viewModel = MapViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.requestWhenInUseAuthorization()
        
    }
    
    private func configure() {
        mapView.delegate = self
        locationManager.delegate = self
    }
    
    private func openChangePermissionsAlert() {
        let title = "Невозможно определить местоположение"
        let message = "Для отображения текущей позиции приложению необходимо дать доступ к геоданным в настройках"
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Настройки", style: .default) { _ in
            guard let url = URL(string: UIApplicationOpenSettingsURLString) else { return }
            UIApplication.shared.open(url)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        vc.addAction(okAction)
        vc.addAction(cancelAction)

        present(vc, animated: true)
    }
    
    // MARK: - Actions
    @IBAction func plusClicked(_ sender: Any) {
        mapView.scaleMap(center: mapView.region.center, zoom: 0.5)
    }
    
    @IBAction func minusClicked(_ sender: Any) {
        mapView.scaleMap(center: mapView.region.center, zoom: 2)
    }
    
    @IBAction func currentLocationClicked(_ sender: Any) {
        let currentStatus = CLLocationManager.authorizationStatus()
        if currentStatus == .denied {
            openChangePermissionsAlert()
        }
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .denied:
            openChangePermissionsAlert()
        default:
            break
        }
    }
    
}

