import MVVMDomain
import XCTest
@testable import MVVMNetwork

final class WeatherAPIClientTests: XCTestCase {
    func test_fetchHistoricalRange_buildsExpectedURL() throws {
        // given
        let configuration = WeatherAPIConfiguration(apiKey: "test-api-key")
        let queryItems = [
            URLQueryItem(name: "key", value: configuration.apiKey),
            URLQueryItem(name: "q", value: configuration.locationQuery),
            URLQueryItem(name: "dt", value: "2024-03-01"),
            URLQueryItem(name: "end_dt", value: "2024-03-07")
        ]

        // when
        let url = try WeatherAPIClient.makeHistoryURL(configuration: configuration, queryItems: queryItems)

        // then
        let urlString = url.absoluteString
        XCTAssertTrue(urlString.contains("history.json"))
        XCTAssertTrue(urlString.contains("key=test-api-key"))
        XCTAssertTrue(urlString.contains("q=Hanoi"))
        XCTAssertTrue(urlString.contains("dt=2024-03-01"))
        XCTAssertTrue(urlString.contains("end_dt=2024-03-07"))
    }
}
