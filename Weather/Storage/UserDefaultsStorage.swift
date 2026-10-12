	
import Foundation

final class UserDefaultsCityStorage: Storage {
    
    private let defaults = UserDefaults.standard
    private let key = "CitiesXD"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func fetchCities() throws -> [City] {
        guard let data = defaults.data(forKey: key) else {
            return []
        }
        
        do {
            return try  decoder.decode([City].self, from: data)
        } catch {
            throw StorageError.decodingFailed
        }
    }
    
    
    func addCity(city: City) throws {
        do {
            var cities = try fetchCities()
            guard !cities.contains(where: { $0.lat == city.lat && $0.lon == city.lon }) else { return }
            cities.append(city)
            let encoded = try encoder.encode(cities)
            defaults.set(encoded, forKey: key)
        } catch let error as StorageError {
            throw error
        } catch {
            throw StorageError.encodingFailed
        }
    }
    
    func reorderCity(city: City) throws {
        do {
            var cities = try fetchCities()
            cities.removeAll(where: {$0.id == city.id})
            cities.insert(city, at: 0)
            let encoded = try encoder.encode(cities)
            defaults.setValue(encoded, forKey: key)
        } catch let error as StorageError {
            throw error
        } catch {
            throw StorageError.reorderFailed
        }
    }
    
    func deleteCity(city: City) throws {
        do {
            var cities = try fetchCities()
            guard let index = cities.firstIndex(where: {$0.id == city.id}) else { return }
            cities.remove(at: index)
            let encoded = try encoder.encode(cities)
            defaults.set(encoded, forKey: key)
        } catch let error as StorageError {
            throw error
        } catch {
            throw StorageError.deleteFailed
        }
    }
}

enum StorageError: LocalizedError {
    case encodingFailed
    case decodingFailed
    case deleteFailed
    case reorderFailed
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Encoding failed"
        case .decodingFailed:
            return "Decoding failed"
        case .deleteFailed:
            return "Failed to delete"
        case .reorderFailed:
            return "Failed to reorder"
        }
    }
}
