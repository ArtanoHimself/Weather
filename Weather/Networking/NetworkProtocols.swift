import Foundation

protocol NetworkServiceProtocol {
    func fetchWeather(lat: Double, lon: Double, lang: Language, units: Units) async throws -> Weather
    func fetchForecast(lat: Double, lon: Double, lang: Language, units: Units) async throws -> Forecast
    func fetchCities(city: String) async throws -> [City]
}
