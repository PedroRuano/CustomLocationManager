import Foundation
import CoreLocation
import Combine

public class LocationManager {
    
    private var locationManager: CLLocationManager
    private var delegate = LocationManagerDelegate()
    public let currentLocation: CurrentValueSubject<CLLocation, Never>
    
    public init() {
        locationManager = CLLocationManager()
        locationManager.delegate = delegate
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        currentLocation = delegate.lastLocation
    }
    
    public func permissionRequest() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    public func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

private class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    public var lastLocation = CurrentValueSubject<CLLocation, Never> (CLLocation(latitude: 0, longitude: 0))
    
    fileprivate func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)")
        lastLocation.send(location)
    }
    
    fileprivate func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clErr = error as? CLError {
            switch clErr.code {
            case .locationUnknown, .denied, .network:
                print("Location request failed with error: \(clErr.localizedDescription)")
            case .headingFailure:
                print("Heading request failed with error: \(clErr.localizedDescription)")
            case .rangingUnavailable, .rangingFailure:
                print("Ranging request failed with error: \(clErr.localizedDescription)")
            case .regionMonitoringDenied, .regionMonitoringFailure, .regionMonitoringSetupDelayed, .regionMonitoringResponseDelayed:
                print("Region monitoring request failed with error: \(clErr.localizedDescription)")
            default:
                print("Unknown location manager error: \(clErr.localizedDescription)")
            }
        } else {
            print("Unknown error occurred while handling location manager error: \(error.localizedDescription)")
        }
    }
    
    fileprivate func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .restricted:
            print("Restricted by parental control")
            
        case .denied:
            print("When user select option Dont't Allow")
            
        case .authorizedAlways:
            print("When user select option Change to Always Allow")
            manager.startUpdatingLocation()
            
        case .authorizedWhenInUse:
            print("When user select option Allow While Using App or Allow Once")
            manager.requestAlwaysAuthorization()
            manager.startUpdatingLocation()
            
        case .notDetermined:
            manager.requestAlwaysAuthorization()
            break
            
        default:
            break
        }
    }
}
