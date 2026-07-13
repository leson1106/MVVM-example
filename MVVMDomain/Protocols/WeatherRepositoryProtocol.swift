import Foundation
import RxSwift

public protocol WeatherRepositoryProtocol {
    func fetchHistoricalRange(startDate: String, endDate: String) -> Observable<[WeatherDay]>
    func fetchHistoricalDates(_ dates: [String]) -> Observable<[WeatherDay]>
    func fetchHistoricalDay(date: String, includeHourly: Bool) -> Observable<WeatherDay>
}
