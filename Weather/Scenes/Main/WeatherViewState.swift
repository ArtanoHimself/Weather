
import Foundation

struct WeatherViewState {
    let dateText: String
    let locationText: String
    let temperatureText: String
    let descriptionText: String
    let backgroundImageName: String
    let details: [WeatherDetail]
    let forecast: [ForecastDetail]
}

nonisolated struct WeatherDetail: Hashable {
    let description: String
    let info: String
}

nonisolated struct ForecastDetail: Hashable {
    let tempText: String
    let imageId: Int
    let windText: String
    let timeText: String
}

