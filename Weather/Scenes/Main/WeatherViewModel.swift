
import Foundation
import Combine

final class WeatherViewModel {
    
    private enum Message {
        static let cityIsNotFound: String = "Please select your location"
    }
    
    @Published var viewState: WeatherViewState?
    @Published var networkErrorMessage: String?
    @Published var storageErrorMessage: String?
    var currentCity: City?
    
    private let networkService: NetworkServiceProtocol
    private let cityStorage: Storage
    
    init(networkService: NetworkServiceProtocol, cityStorage: Storage) {
        self.networkService = networkService
        self.cityStorage = cityStorage
        loadCurrentCity()
    }
    
    func fetchWeather(for city: City) {
        Task {
            do {
                let weather = try await networkService.fetchWeather(lat: city.lat, lon: city.lon, lang: Language.en, units: Units.metric)
                let forecast = try await networkService.fetchForecast(lat: city.lat, lon: city.lon, lang: Language.en, units: Units.metric)
                await MainActor.run {
                    viewState = makeViewState(weather: weather, forecast: forecast)
                }
            } catch {
                await MainActor.run {
                    networkErrorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func loadCurrentCity() {
        do {
            guard let city = try cityStorage.fetchCities().first else {
                storageErrorMessage = Message.cityIsNotFound
                return
            }
            self.currentCity = city
        } catch {
            storageErrorMessage = error.localizedDescription
        }
    }
    
    private func makeViewState(weather: Weather, forecast: Forecast) -> WeatherViewState {
        
        let viewState = WeatherViewState(
            dateText: Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()),
            locationText: "\(weather.name), \(weather.sys.country)",
            temperatureText: "\(Int(weather.main.temp.rounded()))°",
            descriptionText: weather.weather.first?.description.capitalized ?? "",
            backgroundImageName: makeBackgroundImageName(from: weather),
            details: makeDetails(from: weather),
            forecast: makeForecastDetails(from: forecast)
        )
        return viewState
    }
    
    private func makeDetails(from weather: Weather) -> [WeatherDetail] {
        [
            WeatherDetail(description: "Pressure:", info: "\(weather.main.pressure) hPa"),
            WeatherDetail(description: "Humidity:", info: "\(weather.main.humidity)%"),
            WeatherDetail(description: "Feels like:", info: "\(Int(weather.main.feelsLike.rounded()))°"),
            WeatherDetail(description: "Wind:", info: "\(weather.wind.speed) m/s"),
        ]
    }
    
    private func makeForecastDetails(from forecast: Forecast) -> [ForecastDetail] {
        let details = forecast.list.map { forecastItem in
            let date = Date(timeIntervalSince1970: TimeInterval(forecastItem.dt))
            let timeText = date.formatted(.dateTime.weekday(.abbreviated).hour().minute())
            let detail = ForecastDetail(tempText: "\(Int(forecastItem.main.temp.rounded()))°",
                           imageId: forecastItem.weather.first?.id ?? 801,
                           windText: "\(forecastItem.wind.speed) m/s",
                           timeText: "\(timeText)"
            )
            return detail
        }
        return details
    }
    
    private func makeBackgroundImageName(from weather: Weather) -> String {
        guard let id = weather.weather.first?.id else { return "Sunny"}
        
        switch id {
        case 200...232:
            return "Thunder"
        case 300...321:
            return "Rain"
        case 500...531:
            return "Rain"
        case 600...622:
            return "Snow"
        case 800:
            return "Sunny"
        case 801...803:
            return "PartialyCloudy"
        case 804:
            return "PartialyCloudy"
        default:
            return "Cloudy"
        }
    }
}
