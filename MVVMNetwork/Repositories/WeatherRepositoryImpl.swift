import MVVMDomain
import Foundation
import RxSwift

final class WeatherRepositoryImpl: WeatherRepositoryProtocol {
    private let apiClient: WeatherAPIClientProtocol
    private let decoder: JSONDecoder

    init(apiClient: WeatherAPIClientProtocol, decoder: JSONDecoder = JSONDecoder()) {
        self.apiClient = apiClient
        self.decoder = decoder
    }

    func fetchHistoricalRange(startDate: String, endDate: String) -> Observable<[WeatherDay]> {
        apiClient.fetchHistoricalRange(startDate: startDate, endDate: endDate)
            .map(decodeDays)
    }

    func fetchHistoricalDates(_ dates: [String]) -> Observable<[WeatherDay]> {
        apiClient.fetchHistoricalDates(dates)
            .map(decodeDays)
    }

    func fetchHistoricalDay(date: String, includeHourly: Bool) -> Observable<WeatherDay> {
        apiClient.fetchHistoricalDay(date: date, includeHourly: includeHourly)
            .map { data in
                let days = try self.decodeDays(from: data)
                guard let day = days.first(where: { $0.id == date }) ?? days.first else {
                    throw WeatherAPIError.invalidResponse
                }
                return day
            }
    }

    private func decodeDays(from data: Data) throws -> [WeatherDay] {
        do {
            let response = try decoder.decode(HistoricalWeatherResponseDTO.self, from: data)
            return try response.toDomainDays()
        } catch let apiError as WeatherAPIError {
            throw apiError
        } catch {
            let body = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            print("[WeatherAPI] decode failed: \(error)\nbody:\n\(body)")
            throw WeatherAPIError.invalidResponse
        }
    }
}
