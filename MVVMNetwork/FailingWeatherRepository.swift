import MVVMDomain
import RxSwift

public final class FailingWeatherRepository: WeatherRepositoryProtocol {
    public init() {}

    public func fetchHistoricalRange(startDate: String, endDate: String) -> Observable<[WeatherDay]> {
        .error(WeatherAPIError.missingAccessKey)
    }

    public func fetchHistoricalDates(_ dates: [String]) -> Observable<[WeatherDay]> {
        .error(WeatherAPIError.missingAccessKey)
    }

    public func fetchHistoricalDay(date: String, includeHourly: Bool) -> Observable<WeatherDay> {
        .error(WeatherAPIError.missingAccessKey)
    }
}
