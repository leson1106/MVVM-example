import MVVMDomain
import XCTest

final class WeatherUIModelTests: XCTestCase {
    func test_listItem_fromDay_usesNSAttributedStringWithFormattedDate() {
        // given
        let day = WeatherTestFixtures.makeDay()

        // when
        let item = WeatherListItemUIModel(day: day)

        // then
        XCTAssertEqual(item.id, "2024-03-18")
        XCTAssertTrue(item.summary.string.contains("Mar 18, 2024"))
        XCTAssertTrue(item.summary.string.contains("24"))
    }

    func test_detail_fromDay_includesAstroAndHourlyRows() {
        // given
        let hourly = WeatherHourly(
            time: "12:00",
            temperature: "25",
            weatherDescription: "Sunny",
            humidity: "60",
            windSpeed: "10"
        )
        let day = WeatherTestFixtures.makeDay(hourly: [hourly])

        // when
        let detail = WeatherDetailUIModel(day: day)

        // then
        XCTAssertTrue(detail.rows.contains { $0.label == "Sunrise" })
        XCTAssertTrue(detail.rows.contains { $0.label == "12:00" })
        XCTAssertTrue(detail.title.string.contains("Mar 18, 2024"))
    }
}
