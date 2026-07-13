import MVVMDomain
import RxSwift
import XCTest
@testable import MVVMNetwork

final class WeatherRepositoryImplTests: XCTestCase {
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
    }

    func test_fetchHistoricalRange_decodesDTOIntoDomainEntities() {
        // given
        let json = historicalJSON(includeHourly: false)
        let client = WeatherAPIClientMock(returnData: json)
        let repository = WeatherRepositoryImpl(apiClient: client)
        let exp = expectation(description: "decoded")
        var days: [WeatherDay]?

        // when
        repository.fetchHistoricalRange(startDate: "2024-03-12", endDate: "2024-03-18")
            .subscribe(onNext: { value in
                days = value
                exp.fulfill()
             })
            .disposed(by: disposeBag)
        wait(for: [exp], timeout: 2.0)

        // then
        XCTAssertTrue(client.fetchHistoricalRangeCalled)
        XCTAssertEqual(days?.first?.id, "2024-03-18")
        XCTAssertEqual(days?.first?.locationName, "Hanoi")
    }

    func test_fetchHistoricalDates_decodesMultipleDays() {
        // given
        let json = historicalJSON(includeHourly: false)
        let client = WeatherAPIClientMock(returnData: json)
        let repository = WeatherRepositoryImpl(apiClient: client)
        let exp = expectation(description: "decoded dates")

        // when
        repository.fetchHistoricalDates(["2024-03-18"])
            .subscribe(onNext: { _ in exp.fulfill()  })
            .disposed(by: disposeBag)
        wait(for: [exp], timeout: 2.0)

        // then
        XCTAssertTrue(client.fetchHistoricalDatesCalled)
    }

    func test_fetchHistoricalDay_returnsMatchingDayWithHourly() {
        // given
        let json = historicalJSON(includeHourly: true)
        let client = WeatherAPIClientMock(returnData: json)
        let repository = WeatherRepositoryImpl(apiClient: client)
        let exp = expectation(description: "detail day")
        var day: WeatherDay?

        // when
        repository.fetchHistoricalDay(date: "2024-03-18", includeHourly: true)
            .subscribe(onNext: { value in
                day = value
                exp.fulfill()
             })
            .disposed(by: disposeBag)
        wait(for: [exp], timeout: 2.0)

        // then
        XCTAssertTrue(client.fetchHistoricalDayCalled)
        XCTAssertEqual(client.fetchHistoricalDayReceivedIncludeHourly, true)
        XCTAssertEqual(day?.hourly.count, 1)
    }

    private func historicalJSON(includeHourly: Bool) -> Data {
        let hourly = includeHourly ? """
                "hour": [
                  {
                    "time": "2024-03-18 12:00",
                    "temp_c": 25,
                    "condition": { "text": "Sunny" },
                    "humidity": 60,
                    "wind_kph": 10
                  }
                ],
        """ : ""
        let json = """
        {
          "location": { "name": "Hanoi", "country": "Vietnam", "region": "Hanoi" },
          "forecast": {
            "forecastday": [
              {
                "date": "2024-03-18",
                "day": {
                  "maxtemp_c": 28,
                  "mintemp_c": 20,
                  "avgtemp_c": 24,
                  "totalsnow_cm": 0,
                  "uv": 5
                },
                \(hourly)
                "astro": {
                  "sunrise": "06:00 AM",
                  "sunset": "06:30 PM",
                  "moonrise": "07:00 AM",
                  "moonset": "07:30 PM",
                  "moon_phase": "Full Moon",
                  "moon_illumination": "100"
                }
              }
            ]
          }
        }
        """
        return json.data(using: .utf8)!
    }
}

final class WeatherAPIClientMock: WeatherAPIClientProtocol {
    var fetchHistoricalRangeCalled = false
    var fetchHistoricalDatesCalled = false
    var fetchHistoricalDayCalled = false
    var fetchHistoricalDayReceivedIncludeHourly: Bool?
    var returnData: Data

    init(returnData: Data) {
        self.returnData = returnData
    }

    func fetchHistoricalRange(startDate: String, endDate: String) -> Observable<Data> {
        fetchHistoricalRangeCalled = true
        return .just(returnData)
    }

    func fetchHistoricalDates(_ dates: [String]) -> Observable<Data> {
        fetchHistoricalDatesCalled = true
        return .just(returnData)
    }

    func fetchHistoricalDay(date: String, includeHourly: Bool) -> Observable<Data> {
        fetchHistoricalDayCalled = true
        fetchHistoricalDayReceivedIncludeHourly = includeHourly
        return .just(returnData)
    }
}
