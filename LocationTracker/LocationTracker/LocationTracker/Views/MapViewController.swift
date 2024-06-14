//
//  ViewController.swift
//  LocationTracker
//
//  Created by Burak Güner on 13.06.2024.
//

import UIKit
import MapKit
import Combine

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    private var viewModel = MapViewModel()
    private var cancellables = Set<AnyCancellable>()

    @IBOutlet weak var startTrackingButton: UIButton!
    @IBOutlet weak var stopTrackingButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupBindings()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        centerMapOnLatestUserLocation()
    }

    private func centerMapOnLatestUserLocation() {
        guard let location = viewModel.locationsOfTheRoute.last else { return }
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }

    private func setupMapView() {
        mapView.delegate = self
    }

    private func setupBindings() {
        viewModel.$locationsOfTheRoute
            .receive(on: DispatchQueue.main)
            .sink { [weak self] locations in
                self?.updateMapView(with: locations)
            }
            .store(in: &cancellables)

        viewModel.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.handleAuthorizationStatus(status)
            }
            .store(in: &cancellables)
        viewModel.$isTracking
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isTracking in
                if isTracking {
                    self?.startTrackingButton.isEnabled = false
                    self?.stopTrackingButton.isEnabled = true
                } else {
                    self?.startTrackingButton.isEnabled = true
                    self?.stopTrackingButton.isEnabled = false
                }
            }
            .store(in: &cancellables)
    }

    @IBAction func stopTracking(_ sender: Any) {
        viewModel.stopUpdatingLocation()
    }
    
    @IBAction func startTracking(_ sender: Any) {
        viewModel.startUpdatingLocation()
    }

    @IBAction func resetRoute(_ sender: Any) {
        viewModel.resetRoute()
    }

    private func updateMapView(with locations: [LocationModel]) {
        mapView.removeAnnotations(mapView.annotations)
        for location in locations {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            annotation.title = location.address
            let isAlreadyAdded = mapView.annotations.contains { annotation in
                annotation.coordinate.latitude == location.latitude && annotation.coordinate.longitude == location.longitude
            }
            if !isAlreadyAdded {
                mapView.addAnnotation(annotation)
            }
        }
    }

    private func handleAuthorizationStatus(_ status: CLAuthorizationStatus?) {
        if let status = status {
            switch status {
                case .notDetermined, .restricted, .denied:
                    // Handle not authorized
                    break
                case .authorizedAlways, .authorizedWhenInUse:
                    break
                @unknown default:
                    break
            }
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.rightCalloutAccessoryView = UILabel()
            view.titleVisibility = .hidden
            view.animatesWhenAdded = true
        }
        return view
    }
}

