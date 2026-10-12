
import Foundation

nonisolated struct City: Hashable, Codable {
    
    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String?
    let id: UUID
    
    init(cityDTO: CityDTO) {
        self.id = UUID()
        self.name = cityDTO.name
        self.lat = cityDTO.lat
        self.lon = cityDTO.lon
        self.country = cityDTO.country
        self.state = cityDTO.state
    }
}
