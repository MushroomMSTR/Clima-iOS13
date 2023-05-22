//
//  WeatherManager.swift
//  Clima
//
//  Created by NazarStf on 12.05.2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
	func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
	func didFailWithError(error: Error)
}

struct WeatherManager {
	let weatherURL = ApiKey().api // I use api from this site https://openweathermap.org . In the project, you will need to replace let weatherURL = ApiKey().api with your api
	
	var delegate: WeatherManagerDelegate?
	
	func fetchWeather(cityName: String) {
		let urlString = "\(weatherURL)&q=\(cityName)"
		performRequest(with: urlString)
	}
	
	func fetchWeather(latitude: CLLocationDegrees, longitute: CLLocationDegrees) {
		let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitute)"
		performRequest(with: urlString)
	}
	
	func performRequest(with urlString: String) {
		if let url = URL(string: urlString) {
			let session = URLSession(configuration: .default)
			let task = session.dataTask(with: url) { (data, response, error) in
				if error != nil {
					self.delegate?.didFailWithError(error: error!)
					return
				}
				if let safeData = data {
					if let weather = self.parseJSON(safeData) {
						self.delegate?.didUpdateWeather(self, weather: weather)
					}
				}
			}
			task.resume()
		}
	}
	
	func parseJSON(_ weatherData: Data) -> WeatherModel? {
		let decoder = JSONDecoder()
		do {
			let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
			let id = decodedData.weather[0].id
			let temp = decodedData.main.temp
			let name = decodedData.name
			
			let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
			return weather
			
		} catch {
			delegate?.didFailWithError(error: error)
			return nil
		}
	}
	
	
	
}
