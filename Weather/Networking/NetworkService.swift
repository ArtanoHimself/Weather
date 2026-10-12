
import Foundation

final class NetworkService: NetworkServiceProtocol {
    
    private func fetch<T: Decodable>(url: URL, _ type: T.Type) async throws -> T {
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch let urlError as URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkError.noInternetConnection
            case .timedOut:
                throw NetworkError.timedOut
            default:
                throw NetworkError.noInternetConnection
            }
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noInternetConnection
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.badStatusCode(httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
    
    func fetchWeather(lat: Double, lon: Double ,lang: Language, units: Units) async throws -> Weather {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/weather"
        components.queryItems = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lon", value: "\(lon)"),
            URLQueryItem(name: "units", value: units.rawValue),
            URLQueryItem(name: "lang", value: lang.rawValue),
            URLQueryItem(name: "appid", value: APIKey.apiKey)
        ]
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        let weatherDTO = try await fetch(url: url, WeatherDTO.self)
        let weather = Weather(weatherDTO: weatherDTO)
        return weather
    }
    
    func fetchCities(city: String) async throws -> [City] {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/geo/1.0/direct"
        components.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "limit", value: "5"),
            URLQueryItem(name: "appid", value: APIKey.apiKey)
        ]
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        let citiesDTO = try await fetch(url: url, [CityDTO].self)
        let cities = citiesDTO.map{ City(cityDTO: $0) }
        return cities
    }
    
    func fetchForecast(lat: Double, lon: Double, lang: Language, units: Units) async throws -> Forecast {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/forecast"
        components.queryItems = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lon", value: "\(lon)"),
            URLQueryItem(name: "lang", value: lang.rawValue),
            URLQueryItem(name: "cnt", value: "40"),
            URLQueryItem(name: "units", value: "\(units)"),
            URLQueryItem(name: "appid", value: APIKey.apiKey)
        ]
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        let forecastDTO = try await fetch(url: url, ForecastDTO.self)
        let forecast = Forecast(forecastDTO: forecastDTO)
        return forecast
    }
}

enum NetworkError: LocalizedError {
    case invalidURL
    case noInternetConnection
    case timedOut
    case badStatusCode(Int)
    case decodingFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noInternetConnection:
            return "No internet connection"
        case .timedOut:
            return "Request timed out"
        case .badStatusCode(let code):
            return "Bad status code \(code)"
        case .decodingFailed:
            return "Decoding error"
        }
    }
}
