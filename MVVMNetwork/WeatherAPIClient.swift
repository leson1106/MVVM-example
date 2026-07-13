import MVVMDomain
import Foundation
import RxSwift

protocol WeatherAPIClientProtocol {
    func fetchHistoricalRange(startDate: String, endDate: String) -> Observable<Data>
    func fetchHistoricalDates(_ dates: [String]) -> Observable<Data>
    func fetchHistoricalDay(date: String, includeHourly: Bool) -> Observable<Data>
}

final class WeatherAPIClient: WeatherAPIClientProtocol {
    private let configuration: WeatherAPIConfiguration
    private let sessionProvider: () -> URLSession
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private lazy var session: URLSession = sessionProvider()

    init(
        configuration: WeatherAPIConfiguration,
        session: URLSession? = nil
    ) {
        self.configuration = configuration
        if let session {
            self.sessionProvider = { session }
        } else {
            self.sessionProvider = { Self.makeDefaultSession() }
        }
    }

    static func makeDefaultSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.waitsForConnectivity = false
        return URLSession(configuration: configuration)
    }

    static func makeHistoryURL(
        configuration: WeatherAPIConfiguration,
        queryItems: [URLQueryItem]
    ) throws -> URL {
        var components = URLComponents(
            url: configuration.baseURL.appendingPathComponent("history.json"),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = queryItems
        guard let url = components?.url else {
            throw WeatherAPIError.invalidURL
        }
        return url
    }

    func fetchHistoricalRange(startDate: String, endDate: String) -> Observable<Data> {
        let queryItems = baseQueryItems + [
            URLQueryItem(name: "dt", value: startDate),
            URLQueryItem(name: "end_dt", value: endDate)
        ]
        return request(queryItems: queryItems)
    }

    func fetchHistoricalDates(_ dates: [String]) -> Observable<Data> {
        guard dates.isEmpty == false else {
            return .just(emptyResponseData())
        }
        let requests = dates.map { fetchHistoricalDay(date: $0, includeHourly: false) }
        return Observable.zip(requests)
            .map { [decoder, encoder] responses in
                try Self.mergeHistoricalResponses(responses, decoder: decoder, encoder: encoder)
            }
    }

    func fetchHistoricalDay(date: String, includeHourly: Bool) -> Observable<Data> {
        request(queryItems: baseQueryItems + [URLQueryItem(name: "dt", value: date)])
    }

    private var baseQueryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "key", value: configuration.apiKey),
            URLQueryItem(name: "q", value: configuration.locationQuery)
        ]
    }

    private func request(queryItems: [URLQueryItem]) -> Observable<Data> {
        Observable.create { [configuration] observer in
            let url: URL
            do {
                url = try Self.makeHistoryURL(configuration: configuration, queryItems: queryItems)
            } catch {
                observer.onError(error)
                return Disposables.create()
            }

            let curl = Self.makeCurl(for: url)
            print("[WeatherAPI] curl:\n\(curl)")

            let session = self.session
            let task = session.dataTask(with: url) { data, response, error in
                if let error {
                    print("[WeatherAPI] response error: \(error.localizedDescription)")
                    observer.onError(error)
                    return
                }
                let statusCode = (response as? HTTPURLResponse)?.statusCode
                let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? "<empty>"
                print("[WeatherAPI] status: \(statusCode.map(String.init) ?? "nil")")
                print("[WeatherAPI] response:\n\(body)")

                if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) == false {
                    observer.onError(WeatherAPIError.httpStatus(httpResponse.statusCode))
                    return
                }
                guard let data else {
                    observer.onError(WeatherAPIError.invalidResponse)
                    return
                }
                observer.onNext(data)
                observer.onCompleted()
            }
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }

    private static func makeCurl(for url: URL) -> String {
        "curl -sS '\(url.absoluteString)'"
    }

    private func emptyResponseData() -> Data {
        Data("{\"forecast\":{\"forecastday\":[]}}".utf8)
    }

    private static func mergeHistoricalResponses(
        _ dataArray: [Data],
        decoder: JSONDecoder,
        encoder: JSONEncoder
    ) throws -> Data {
        var allDays: [ForecastDayDTO] = []
        var location: LocationDTO?
        for data in dataArray {
            let response = try decoder.decode(HistoricalWeatherResponseDTO.self, from: data)
            if let error = response.error {
                throw WeatherAPIError.api(message: error.message ?? "Unknown API error")
            }
            if location == nil {
                location = response.location
            }
            allDays.append(contentsOf: response.forecast?.forecastday ?? [])
        }
        let merged = HistoricalWeatherResponseDTO(
            location: location,
            forecast: ForecastDTO(forecastday: allDays.sorted { $0.date < $1.date }),
            error: nil
        )
        return try encoder.encode(merged)
    }
}
