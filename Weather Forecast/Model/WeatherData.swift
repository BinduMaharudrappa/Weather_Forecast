//
//  WeatherData.swift
//  Weather Forecast
//
//  Created by Bindu Maharudrappa on 29.08.20.
//  Copyright © 2020 Bindu Maharudrappa. All rights reserved.
//

import Foundation

struct WeatherData: Codable {
    let name: String
    let main: Main
}

struct Main: Codable {
    let temp: Double
}
