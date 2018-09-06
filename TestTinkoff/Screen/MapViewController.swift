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
        viewModel.delegate = self
        mapView.delegate = self
        mapView.register(DepositionPointAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: DepositionPointAnnotationView.reuseIdentifier)
        locationManager.delegate = self
    }
    
    private func openChangePermissionsAlert() {
        let settingsButton = AlertButton(title: viewModel.settingsTitle) { _ in
            guard let url = URL(string: UIApplicationOpenSettingsURLString) else { return }
            UIApplication.shared.open(url)
        }
        let cancelButton = AlertButton(title: viewModel.cancelTitle, style: .cancel)
        let parameters = AlertParameters(title: viewModel.locationPermissionTitle,
                                         message: viewModel.locationPermissionMessage,
                                         firstButton: settingsButton,
                                         secondButton: cancelButton)
        let vc = AlertControllerFactory.alertVCWith(parameters: parameters)
        present(vc, animated: true)
    }
    
    private func locationDidUpdated(location: CLLocation) {
        viewModel.currentLocation = location
        
        if viewModel.locationReceivedFirstTime {
            mapView.setPosision(coordinate: location.coordinate)
            viewModel.locationReceivedFirstTime = false
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
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: DepositionPointAnnotationView.reuseIdentifier) as? DepositionPointAnnotationView
            view?.imageView.setImageWith(url: annotation.imageUrl)
            return view
        default:
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let depositionPointAnnotation = view.annotation as? DepositionPointAnnotation,
            let pointName = depositionPointAnnotation.pointName,
            let pointAddress = depositionPointAnnotation.address else { return }
        
        let parameters = AlertParameters(title: pointName,
                                         message: pointAddress,
                                         firstButton: AlertButton(title: viewModel.okTitle))
        let vc = AlertControllerFactory.alertVCWith(parameters: parameters)
        present(vc, animated: true)
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
    
    func updateAnnotations(new: [MKAnnotation], toRemove: [MKAnnotation]) {
        mapView.removeAnnotations(toRemove)
        mapView.addAnnotations(new)
    }
    
    func onError(error: Error) {
        let parameters = AlertParameters(title: viewModel.errorTitle,
                                         message: error.localizedDescription,
                                         firstButton: AlertButton(title: viewModel.okTitle))
        let vc = AlertControllerFactory.alertVCWith(parameters: parameters)
        present(vc, animated: true)
    }
    
    func loadingChanged(isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
}
