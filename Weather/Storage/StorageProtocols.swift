
import Foundation

protocol Storage {
    
    func fetchCities() throws -> [City]
    func addCity(city: City) throws
    func reorderCity(city: City) throws
    func deleteCity(city: City) throws
}
