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
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    private let locationManager = CLLocationManager()
    private let viewModel = MapViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.requestWhenInUseAuthorization()
        updatePoints()
    }
    
    private func configure() {
        viewModel.delegte = self
        mapView.delegate = self
        mapView.register(DepositionPointAnnotationView.self, forAnnotationViewWithReuseIdentifier: "deposition_point")
        locationManager.delegate = self
        
        viewModel.annotationsUpdated = { [unowned self] new, toRemove in
            self.mapView.removeAnnotations(toRemove)
            self.mapView.addAnnotations(new)
        }
        
        viewModel.onError = { error in
            print("Error \(error.localizedDescription)")
        }
        
        viewModel.loadingChanged = { [unowned self] isLoading in
            if isLoading {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
        
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
    
    private func locationDidUpdated(location: CLLocation) {
        viewModel.currentLocation = location
        
        if viewModel.needSetCurrentLocation {
            mapView.setPosision(coordinate: location.coordinate)
            viewModel.needSetCurrentLocation = false
        }
    }
    
    private func updatePoints() {
        viewModel.needUpdatePoints(latitude: mapView.centerCoordinate.latitude,
                                   longitude: mapView.centerCoordinate.longitude,
                                   radius: mapView.visibleMapRadius)
    }
    
    // MARK: - Actions
    @IBAction private func plusClicked(_ sender: Any) {
        mapView.scaleMap(zoom: 0.5)
    }
    
    @IBAction private func minusClicked(_ sender: Any) {
        mapView.scaleMap(zoom: 2)
    }
    
    @IBAction private func currentLocationClicked(_ sender: Any) {
        let currentStatus = CLLocationManager.authorizationStatus()
        if currentStatus == .denied {
            openChangePermissionsAlert()
        }
        
        if let currentLocation = viewModel.currentLocation {
            mapView.setPosision(coordinate: currentLocation.coordinate)
        } else {
            viewModel.needSetCurrentLocation = true
        }
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updatePoints()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case let annotation as DepositionPointAnnotation:
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: "deposition_point") as? DepositionPointAnnotationView
            view?.imageView.setImageWith(url: annotation.imageUrl)
            return view
        default:
            return nil
        }
    }
    
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationDidUpdated(location: location)
        }
    }
    
}

extension MapViewController: MapViewModelDelegate {
    
    func currentAnnotation() -> [MKAnnotation] {
        return mapView.annotations
    }
    
}
