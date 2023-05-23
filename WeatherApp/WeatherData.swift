//
//  WeatherData.swift
//  WeatherApp
//
//  Created by Vineela Janjirala on 5/22/23.
//

import Foundation

struct WeatherData: Codable {
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let description: String
    let icon: String
}
