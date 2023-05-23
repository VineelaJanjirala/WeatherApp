//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Vineela Janjirala on 5/22/23.
//

import UIKit

    class WeatherViewController: UIViewController, WeatherViewModelDelegate {
        @IBOutlet private weak var cityTextField: UITextField!
        @IBOutlet private weak var weatherImageView: UIImageView!
        @IBOutlet private weak var temperatureLabel: UILabel!
        @IBOutlet private weak var descriptionLabel: UILabel!
        
        private var viewModel: WeatherViewModel!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            viewModel = WeatherViewModel()
            viewModel.delegate = self
            viewModel.requestLocationPermission()
            loadLastSearchedCity()
        }
        
        @IBAction private func searchButtonTapped(_ sender: UIButton) {
            guard let city = cityTextField.text else { return }
            viewModel.getCurrentWeatherData(for: city)
        }
        
        private func loadLastSearchedCity() {
            if let lastSearchedCity = UserDefaults.standard.string(forKey: "lastSearchedCity") {
                cityTextField.text = lastSearchedCity
                viewModel.getCurrentWeatherData(for: lastSearchedCity)
            }
        }
        
        func weatherDataDidChange() {
            guard let weatherData = viewModel.weatherData else { return }
            
            let temperature = weatherData.main.temp - 273.15
            temperatureLabel.text = "Temperature: \(String(format: "%.1f", temperature))°C"
            descriptionLabel.text = weatherData.weather.first?.description
            
            if let iconName = weatherData.weather.first?.icon {
                let urlString = "http://openweathermap.org/img/w/\(iconName).png"
                if let url = URL(string: urlString), let data = try? Data(contentsOf: url) {
                    weatherImageView.image = UIImage(data: data)
                }
            }
            
            UserDefaults.standard.set(cityTextField.text, forKey: "lastSearchedCity")
        }
    }
