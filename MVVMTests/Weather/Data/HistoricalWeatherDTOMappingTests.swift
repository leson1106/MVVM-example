import MVVMDomain
import XCTest
@testable import MVVMNetwork

final class HistoricalWeatherDTOMappingTests: XCTestCase {
    func test_toDomainDays_convertsDTOToDomainEntityWithFormattedDate() throws {
        // given
        let json = """
        {
          "location": { "name": "Hanoi", "country": "Vietnam", "region": "Hanoi" },
          "forecast": {
            "forecastday": [
              {
                "date": "2015-01-21",
                "day": {
                  "maxtemp_c": 26,
                  "mintemp_c": 18,
                  "avgtemp_c": 22,
                  "totalsnow_cm": 0,
                  "uv": 4
                },
                "astro": {
                  "sunrise": "06:30 AM",
                  "sunset": "05:45 PM",
                  "moonrise": "07:00 AM",
                  "moonset": "06:00 PM",
                  "moon_phase": "Waxing Crescent",
                  "moon_illumination": "12"
                }
              }
            ]
          }
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(HistoricalWeatherResponseDTO.self, from: json)

        // when
        let days = try dto.toDomainDays()

        // then
        XCTAssertEqual(days.count, 1)
        XCTAssertEqual(days.first?.id, "2015-01-21")
        XCTAssertEqual(days.first?.minTemperature, "18")
        XCTAssertFalse(days.first?.displayDate.contains("2015-01-21") == true)
    }

    func test_toDomainDays_apiError_throws() {
        // given
        let response = HistoricalWeatherResponseDTO(
            location: nil,
            forecast: nil,
            error: APIErrorDTO(code: 601, message: "Invalid key")
        )

        // then
        XCTAssertThrowsError(try response.toDomainDays())
    }

    func test_toDomainDays_acceptsNumericMoonIllumination() throws {
        // given
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
                "astro": {
                  "sunrise": "06:00 AM",
                  "sunset": "06:30 PM",
                  "moonrise": "07:00 AM",
                  "moonset": "07:30 PM",
                  "moon_phase": "Full Moon",
                  "moon_illumination": 100
                }
              }
            ]
          }
        }
        """.data(using: .utf8)!

        // when
        let dto = try JSONDecoder().decode(HistoricalWeatherResponseDTO.self, from: json)
        let days = try dto.toDomainDays()

        // then
        XCTAssertEqual(days.first?.astro.moonIllumination, "100")
    }
}
