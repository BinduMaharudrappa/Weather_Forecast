//
//  WeatherModel.swift
//  Weather Forecast
//
//  Created by Bindu Maharudrappa on 29.08.20.
//  Copyright © 2020 Bindu Maharudrappa. All rights reserved.
//

import UIKit

struct WeatherModel {
    let cityName: String
    let temperature: Double
    
    var temperatureCelsius: String {
        return String(format: "%.f", temperature)
    }
    
    // provides the color based on the temperature value
    var mainViewBGColor: UIColor {
        if Int(temperatureCelsius)! < 10 {
            return #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        } else if Int(temperatureCelsius)! < 25 {
            return #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
        }
        else {
            return #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        }
    }
    
    var temperatureFahrenheit: String {
        let fahrenheitValue = (temperature * 9)/5 + 32
        return String(format: "%.f", fahrenheitValue)
    }

}
