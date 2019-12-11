//
//  WeatherAPI.swift
//  StreamDemo
//
//  Created by James Langdon on 12/5/19.
//  Copyright © 2019 corporatelangdon. All rights reserved.
//

import Foundation
import Combine

enum City: String, CaseIterable {
    case atlanta = "Atlanta"
    case chicago = "Chicago"
    case paris = "Paris"
    case london = "London"
    case tokyo = "Tokyo"
    case losAngeles = "Los Angeles"
    case berlin = "Berlin"
    case mumbai = "Mumbai"
    
    var queryEncoded: String {
        return rawValue.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? rawValue
    }
    
    static var all: [City] {
        return City.allCases
            .sorted { $0.rawValue < $1.rawValue }
    }
}

struct Weather: Codable {
    var temp: Double
}

struct WeatherResponse: Codable {
    var name: String
    var main: Weather
}

struct WeatherApiConstants {
    private enum QueryKey: String {
        case appid
        case units
        case city = "q"
    }
    
    enum Unit: String {
        case metric
        case imperial
        case kelvin = "standard"
        
        var symbol: String {
            switch self {
            case .metric: return "℃"
            case .imperial: return "℉"
            case .kelvin: return "K"
            }
        }
    }

    private static let baseUrl = "http://api.openweathermap.org/data/2.5/weather"
    private static let apiKey = "fe4efbddd28cb98a91938f908fedc617"
    
    static func url(for city: City, with unit: Unit = .imperial) -> URL {
        var urlComponents = URLComponents(string: baseUrl)
        let appidQueryItem = URLQueryItem(name: QueryKey.appid.rawValue, value: apiKey)
        let unitsQueryItem = URLQueryItem(name: QueryKey.units.rawValue, value: unit.rawValue)
        let cityQueryItem = URLQueryItem(name: QueryKey.city.rawValue, value: city.queryEncoded)
        urlComponents?.queryItems = [
            appidQueryItem,
            unitsQueryItem,
            cityQueryItem
        ]
        return urlComponents!.url!
    }
}

class WeatherAPI {
    
    func retrieve(for city: City, with unit: WeatherApiConstants.Unit = .imperial) -> AnyPublisher<WeatherResponse, Error> {
        let url = WeatherApiConstants.url(for: city, with: unit)
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
}
