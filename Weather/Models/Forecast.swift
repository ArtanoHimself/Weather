
import Foundation

struct Forecast {
    
    let list: [ForecastList]
    
    init(forecastDTO: ForecastDTO) {
        self.list = forecastDTO.list.map {
            ForecastList (dt: $0.dt,
                          main: ForecastMain(temp: $0.main.temp),
                          weather: $0.weather.map { ForecastWeather(id: $0.id) },
                          wind: ForecastWind(speed: $0.wind.speed))
        }
    }
    
    struct ForecastList {
        let dt: Int
        let main: ForecastMain
        let weather: [ForecastWeather]
        let wind: ForecastWind
    }
    
    struct ForecastMain {
        let temp: Double
    }
    
    struct ForecastWeather {
        let id: Int
    }
    
    struct ForecastWind {
        let speed: Double
    }
}
