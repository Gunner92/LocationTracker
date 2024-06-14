//
//  LocationViewModel.swift
//  LocationTracker
//
//  Created by Burak Güner on 13.06.2024.
//

import Foundation
import CoreLocation

class MapViewModel: NSObject, ObservableObject {

    @Published var locationsOfTheRoute: [LocationModel] = []
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var isTracking: Bool = true

    private var locationManager = CLLocationManager()
    private var previousLocation: CLLocation?

    override init() {
        super.init()
        if let previousLocations = LocationStorageManager.sharedInstance.getLocations() {
            locationsOfTheRoute = previousLocations
        }
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }

    func resetRoute() {
        locationsOfTheRoute.removeAll()
        previousLocation = nil
    }
}

extension MapViewModel: CLLocationManagerDelegate {

    func startUpdatingLocation() {
        isTracking = true
        locationManager.startUpdatingLocation()
    }


    func stopUpdatingLocation() {
        isTracking = false
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }

        if let previousLocation = previousLocation {
            let distance = currentLocation.distance(from: previousLocation)
            if distance > 100 {
                addLocation(currentLocation)
                self.previousLocation = currentLocation
            }
        } else {
            addLocation(currentLocation)
            self.previousLocation = currentLocation
        }
    }

    private func addLocation(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            var address: String? = nil
            if let placemark = placemarks?.first {
                address = [placemark.name, placemark.locality].compactMap { $0 }.joined(separator: ", ")
            }

            let newLocation = LocationModel(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, address: address)
            self?.locationsOfTheRoute.append(newLocation)
            if let locationsOfTheRoute = self?.locationsOfTheRoute {
                LocationStorageManager.sharedInstance.storeLocations(locations: locationsOfTheRoute)
            }
        }

    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.startUpdatingLocation()
            isTracking = true
        }
    }
}
