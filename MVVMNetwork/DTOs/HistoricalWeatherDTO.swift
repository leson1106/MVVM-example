import Foundation
import MVVMDomain

struct HistoricalWeatherResponseDTO: Codable {
    let location: LocationDTO?
    let forecast: ForecastDTO?
    let error: APIErrorDTO?

    func toDomainDays() throws -> [WeatherDay] {
        if let error {
            let message = error.message ?? "Unknown API error"
            throw WeatherAPIError.api(message: message)
        }
        guard let forecastDays = forecast?.forecastday else {
            return []
        }
        return forecastDays.compactMap { $0.toDomain(location: location) }
    }
}

struct APIErrorDTO: Codable {
    let code: Int?
    let message: String?
}

struct LocationDTO: Codable {
    let name: String?
    let country: String?
    let region: String?
}

struct ForecastDTO: Codable {
    let forecastday: [ForecastDayDTO]
}

struct ForecastDayDTO: Codable {
    let date: String
    let day: DayDTO
    let astro: AstroDTO
    let hour: [HourDTO]?

    func toDomain(location: LocationDTO?) -> WeatherDay? {
        guard date.isEmpty == false else { return nil }
        let hourly = (hour ?? []).map { $0.toDomain() }
        return WeatherDay(
            id: date,
            locationName: location?.name ?? MVVMDomain.weatherLocationQuery,
            region: location?.region ?? "-",
            country: location?.country ?? "-",
            displayDate: Self.formatDisplayDate(date),
            minTemperature: Self.formatTemperature(day.mintempC),
            maxTemperature: Self.formatTemperature(day.maxtempC),
            averageTemperature: Self.formatTemperature(day.avgtempC),
            totalSnow: Self.formatNumber(day.totalsnowCm),
            sunHour: "-",
            uvIndex: Self.formatNumber(day.uv),
            astro: astro.toDomain(),
            hourly: hourly
        )
    }

    private static func formatDisplayDate(_ apiDate: String) -> String {
        guard let date = apiDateFormatter.date(from: apiDate) else {
            return apiDate
        }
        return displayDateFormatter.string(from: date)
    }

    private static func formatTemperature(_ value: Double?) -> String {
        guard let value else { return "-" }
        if value.rounded() == value {
            return String(format: "%.0f", value)
        }
        return String(format: "%.1f", value)
    }

    private static func formatNumber(_ value: (some Numeric)?) -> String {
        guard let value else { return "-" }
        return "\(value)"
    }

    private static let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

struct DayDTO: Codable {
    let maxtempC: Double?
    let mintempC: Double?
    let avgtempC: Double?
    let totalsnowCm: Double?
    let uv: Double?

    enum CodingKeys: String, CodingKey {
        case maxtempC = "maxtemp_c"
        case mintempC = "mintemp_c"
        case avgtempC = "avgtemp_c"
        case totalsnowCm = "totalsnow_cm"
        case uv
    }
}

struct AstroDTO: Codable {
    let sunrise: String?
    let sunset: String?
    let moonrise: String?
    let moonset: String?
    let moonPhase: String?
    let moonIllumination: String?

    enum CodingKeys: String, CodingKey {
        case sunrise
        case sunset
        case moonrise
        case moonset
        case moonPhase = "moon_phase"
        case moonIllumination = "moon_illumination"
    }

    init(
        sunrise: String?,
        sunset: String?,
        moonrise: String?,
        moonset: String?,
        moonPhase: String?,
        moonIllumination: String?
    ) {
        self.sunrise = sunrise
        self.sunset = sunset
        self.moonrise = moonrise
        self.moonset = moonset
        self.moonPhase = moonPhase
        self.moonIllumination = moonIllumination
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sunrise = try container.decodeIfPresent(String.self, forKey: .sunrise)
        sunset = try container.decodeIfPresent(String.self, forKey: .sunset)
        moonrise = try container.decodeIfPresent(String.self, forKey: .moonrise)
        moonset = try container.decodeIfPresent(String.self, forKey: .moonset)
        moonPhase = try container.decodeIfPresent(String.self, forKey: .moonPhase)
        moonIllumination = try Self.decodeFlexibleString(from: container, forKey: .moonIllumination)
    }

    func toDomain() -> WeatherAstro {
        WeatherAstro(
            sunrise: sunrise ?? "-",
            sunset: sunset ?? "-",
            moonrise: moonrise ?? "-",
            moonset: moonset ?? "-",
            moonPhase: moonPhase ?? "-",
            moonIllumination: moonIllumination ?? "-"
        )
    }

    private static func decodeFlexibleString(
        from container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) throws -> String? {
        if let value = try? container.decodeIfPresent(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeIfPresent(Int.self, forKey: key) {
            return String(value)
        }
        if let value = try? container.decodeIfPresent(Double.self, forKey: key) {
            return String(Int(value))
        }
        return nil
    }
}

struct HourDTO: Codable {
    let time: String?
    let tempC: Double?
    let condition: ConditionDTO?
    let humidity: Int?
    let windKph: Double?

    enum CodingKeys: String, CodingKey {
        case time
        case tempC = "temp_c"
        case condition
        case humidity
        case windKph = "wind_kph"
    }

    func toDomain() -> WeatherHourly {
        WeatherHourly(
            time: time ?? "-",
            temperature: Self.formatTemperature(tempC),
            weatherDescription: condition?.text ?? "-",
            humidity: Self.formatNumber(humidity),
            windSpeed: Self.formatNumber(windKph)
        )
    }

    private static func formatTemperature(_ value: Double?) -> String {
        guard let value else { return "-" }
        if value.rounded() == value {
            return String(format: "%.0f", value)
        }
        return String(format: "%.1f", value)
    }

    private static func formatNumber(_ value: (some Numeric)?) -> String {
        guard let value else { return "-" }
        return "\(value)"
    }
}

struct ConditionDTO: Codable {
    let text: String?
}
