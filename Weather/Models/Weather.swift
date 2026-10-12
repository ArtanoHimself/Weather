
import Foundation

struct Weather {
    
    let weather: [WeatherCondition]
    let main: Main
    let wind: Wind
    let name: String
    let sys: Sys
    
    init(weatherDTO: WeatherDTO) {
        self.weather = weatherDTO.weather.map {
            WeatherCondition(
                id: $0.id,
                description: $0.description
            )
        }

        self.main = Main(temp: weatherDTO.main.temp,
                         feelsLike: weatherDTO.main.feelsLike,
                         pressure: weatherDTO.main.pressure,
                         humidity: weatherDTO.main.humidity
        )
        self.wind = Wind(speed: weatherDTO.wind.speed)
        self.name = weatherDTO.name
        self.sys = Sys(country: weatherDTO.sys.country)
    }

    struct WeatherCondition {
        let id: Int
        let description: String
    }

    struct Main {
        let temp: Double
        let feelsLike: Double
        let pressure: Int
        let humidity: Int
    }

    struct Wind {
        let speed: Double
    }

    struct Sys {
        let country: String
    }
}
