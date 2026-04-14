// LocationService.swift
// IOS_CW2_Supportives

import Foundation
import CoreLocation
import Combine

final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    // MARK: - Published
    @Published var userLocation: CLLocationCoordinate2D? = nil
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: String? = nil

    // MARK: - Private
    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate           = self
        manager.desiredAccuracy    = kCLLocationAccuracyHundredMeters
        manager.distanceFilter     = 50
        // Start with Colombo as fallback
        userLocation = AppConstants.defaultCoordinate
    }

    // MARK: - Public API
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdating() {
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
        }
    }

    func stopUpdating() {
        manager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation  = loc.coordinate
            self.locationError = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.locationError = error.localizedDescription
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                self.startUpdating()
            case .denied, .restricted:
                self.locationError = "Location access denied. Using default coordinates."
            default:
                break
            }
        }
    }

    // MARK: - Helpers
    func distance(to coord: CLLocationCoordinate2D) -> Double {
        let from = CLLocation(latitude: userLocation?.latitude  ?? AppConstants.defaultLatitude,
                              longitude: userLocation?.longitude ?? AppConstants.defaultLongitude)
        let to   = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        return from.distance(from: to) / 1000.0
    }
}
