
import Foundation

struct ForecastDTO: Decodable {
    let list: [ForecastListDTO]
}

struct ForecastListDTO: Decodable {
    let dt: Int
    let main: ForecastMainDTO
    let weather: [ForecastWeatherDTO]
    let wind: ForecastWindDTO
}

struct ForecastMainDTO: Decodable {
    let temp: Double
}

struct ForecastWeatherDTO: Decodable {
    let id: Int
}

struct ForecastWindDTO: Decodable {
    let speed: Double
}
