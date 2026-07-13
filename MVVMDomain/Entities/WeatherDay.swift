import Foundation

public struct WeatherAstro: Equatable {
    public let sunrise: String
    public let sunset: String
    public let moonrise: String
    public let moonset: String
    public let moonPhase: String
    public let moonIllumination: String

    public init(
        sunrise: String,
        sunset: String,
        moonrise: String,
        moonset: String,
        moonPhase: String,
        moonIllumination: String
    ) {
        self.sunrise = sunrise
        self.sunset = sunset
        self.moonrise = moonrise
        self.moonset = moonset
        self.moonPhase = moonPhase
        self.moonIllumination = moonIllumination
    }
}

public struct WeatherHourly: Equatable {
    public let time: String
    public let temperature: String
    public let weatherDescription: String
    public let humidity: String
    public let windSpeed: String

    public init(
        time: String,
        temperature: String,
        weatherDescription: String,
        humidity: String,
        windSpeed: String
    ) {
        self.time = time
        self.temperature = temperature
        self.weatherDescription = weatherDescription
        self.humidity = humidity
        self.windSpeed = windSpeed
    }
}

public struct WeatherDay: Equatable {
    public let id: String
    public let locationName: String
    public let region: String
    public let country: String
    public let displayDate: String
    public let minTemperature: String
    public let maxTemperature: String
    public let averageTemperature: String
    public let totalSnow: String
    public let sunHour: String
    public let uvIndex: String
    public let astro: WeatherAstro
    public let hourly: [WeatherHourly]

    public init(
        id: String,
        locationName: String,
        region: String,
        country: String,
        displayDate: String,
        minTemperature: String,
        maxTemperature: String,
        averageTemperature: String,
        totalSnow: String,
        sunHour: String,
        uvIndex: String,
        astro: WeatherAstro,
        hourly: [WeatherHourly]
    ) {
        self.id = id
        self.locationName = locationName
        self.region = region
        self.country = country
        self.displayDate = displayDate
        self.minTemperature = minTemperature
        self.maxTemperature = maxTemperature
        self.averageTemperature = averageTemperature
        self.totalSnow = totalSnow
        self.sunHour = sunHour
        self.uvIndex = uvIndex
        self.astro = astro
        self.hourly = hourly
    }
}
