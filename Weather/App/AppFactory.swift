
import Foundation

final class AppFactory {
    
    static func createWeatherViewController() -> WeatherViewController {
        let networkService = NetworkService()
        let cityStorage = UserDefaultsCityStorage()
        let viewModel = WeatherViewModel(networkService: networkService, cityStorage: cityStorage)
        let viewController = WeatherViewController(viewModel: viewModel)
        return viewController
    }
    
    static func createCitiesViewController() -> CitiesViewController {
        let networkService = NetworkService()
        let cityStorage = UserDefaultsCityStorage()
        let viewModel = CitiesViewModel(networkService: networkService,
                                        cityStorage: cityStorage)
        let viewController = CitiesViewController(viewModel: viewModel)
        return viewController
    }
}
