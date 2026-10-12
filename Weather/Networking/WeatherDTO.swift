import Foundation

struct WeatherDTO: Decodable {
    let weather: [WeatherConditionDTO]
    let main: MainDTO
    let wind: WindDTO
    let name: String
    let sys: SysDTO

    struct WeatherConditionDTO: Decodable {
        let id: Int
        let description: String
    }

    struct MainDTO: Decodable {
        let temp: Double
        let feelsLike: Double
        let pressure: Int
        let humidity: Int
        
        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case pressure
            case humidity
        }
    }

    struct WindDTO: Decodable {
        let speed: Double
    }

    struct SysDTO: Decodable {
        let country: String
    }
}
