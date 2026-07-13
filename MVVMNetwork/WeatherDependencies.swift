import MVVMDomain
import Foundation

public enum WeatherDependencies {
    public static func makeRepository() -> WeatherRepositoryProtocol {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return FailingWeatherRepository()
        }
        let configuration = WeatherAPIConfiguration()
        let apiClient = WeatherAPIClient(configuration: configuration)
        return WeatherRepositoryImpl(apiClient: apiClient)
    }

    public static func makeBookmarkStore() -> BookmarkStoreProtocol {
        UserDefaultsBookmarkStore()
    }
}
