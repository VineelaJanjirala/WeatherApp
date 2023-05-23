//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Vineela Janjirala on 5/22/23.
//

import Foundation
import UIKit
import CoreLocation

protocol WeatherViewModelDelegate: AnyObject {
    func weatherDataDidChange()
}

class WeatherViewModel: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let apiKey = "5a4aee872c0ad2aeaaba5555e74bf3e0"
    
    var weatherData: WeatherData? {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.weatherDataDidChange()
            }
        }
    }
    
    weak var delegate: WeatherViewModelDelegate?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentWeatherData(for city: String) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self, let data = data else { return }
            
            if let weatherData = try? JSONDecoder().decode(WeatherData.self, from: data) {
                self.weatherData = weatherData
            } else {
                print("Error parsing JSON data")
            }
        }
        task.resume()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error requesting location: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error reverse geocoding location: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first {
                if let city = placemark.locality {
                    self.getCurrentWeatherData(for: city)
                }
            }
        }
    }
}
