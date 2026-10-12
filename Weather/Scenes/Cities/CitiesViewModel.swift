
import Foundation
import Combine

final class CitiesViewModel {
    
    @Published var searchedCities: [City] = []
    @Published var savedCities: [City] = []
    @Published var searchQuery: String = ""
    @Published var networkErrorMessage: String?
    @Published var storageErrorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let networkService: NetworkServiceProtocol
    private let cityStorage: Storage
    
    init(networkService: NetworkServiceProtocol, cityStorage: Storage) {
        self.networkService = networkService
        self.cityStorage = cityStorage
        setupDebounce()
        loadSavedCities()
    }
    
    private func searchCities(city: String) {
        Task {
            do {
                let fetchedCities = try await networkService.fetchCities(city: city)
                await MainActor.run {
                    searchedCities = fetchedCities
                }
            } catch {
                await MainActor.run {
                    networkErrorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func setupDebounce() {
        $searchQuery
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard !query.isEmpty else {
                    self?.searchedCities = []
                    return
                }
                self?.searchCities(city: query)
            }
            .store(in: &cancellables)
    }
    
    func loadSavedCities() {
        do {
            savedCities = try cityStorage.fetchCities()
        } catch {
            storageErrorMessage = error.localizedDescription
        }
    }
    
    func saveCity(city: City) {
        do {
            try cityStorage.addCity(city: city)
            loadSavedCities()
        } catch {
            storageErrorMessage = error.localizedDescription
        }
    }
    
    func deleteCity(city: City) {
        do {
            try cityStorage.deleteCity(city: city)
            loadSavedCities()
        } catch {
            storageErrorMessage = error.localizedDescription
        }
    }
    
    func reorderCity(city: City) {
        do {
            try cityStorage.reorderCity(city: city)
            loadSavedCities()
        } catch {
            storageErrorMessage = error.localizedDescription
        }
    }
    
    func clearSearchQuery() {
        searchQuery = ""
    }
}
