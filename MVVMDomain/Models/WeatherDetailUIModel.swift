import UIKit

public struct WeatherDetailRowUIModel: Equatable {
    public let label: String
    public let value: NSAttributedString

    public init(label: String, value: NSAttributedString) {
        self.label = label
        self.value = value
    }

    public static func == (lhs: WeatherDetailRowUIModel, rhs: WeatherDetailRowUIModel) -> Bool {
        lhs.label == rhs.label && lhs.value.isEqual(to: rhs.value)
    }
}

public struct WeatherDetailUIModel: Equatable {
    public let title: NSAttributedString
    public let rows: [WeatherDetailRowUIModel]

    public init(title: NSAttributedString, rows: [WeatherDetailRowUIModel]) {
        self.title = title
        self.rows = rows
    }

    public init(day: WeatherDay) {
        title = NSAttributedString(
            string: day.displayDate,
            attributes: [
                .font: UIFont.boldSystemFont(ofSize: 22),
                .foregroundColor: UIColor.label
            ]
        )

        var rows: [WeatherDetailRowUIModel] = [
            Self.row("Location", "\(day.locationName), \(day.region), \(day.country)"),
            Self.row("Average", "\(day.averageTemperature)°C"),
            Self.row("Min / Max", "\(day.minTemperature)°C / \(day.maxTemperature)°C"),
            Self.row("Total Snow", "\(day.totalSnow) cm"),
            Self.row("Sun Hours", day.sunHour),
            Self.row("UV Index", day.uvIndex),
            Self.row("Sunrise", day.astro.sunrise),
            Self.row("Sunset", day.astro.sunset),
            Self.row("Moonrise", day.astro.moonrise),
            Self.row("Moonset", day.astro.moonset),
            Self.row("Moon Phase", day.astro.moonPhase),
            Self.row("Moon Illumination", day.astro.moonIllumination)
        ]

        if day.hourly.isEmpty == false {
            rows.append(Self.row("Hourly", ""))
            for hour in day.hourly {
                rows.append(
                    Self.row(
                        hour.time,
                        "\(hour.temperature)°C  \(hour.weatherDescription)  H:\(hour.humidity)%  W:\(hour.windSpeed) km/h"
                    )
                )
            }
        }

        self.rows = rows
    }

    public static func == (lhs: WeatherDetailUIModel, rhs: WeatherDetailUIModel) -> Bool {
        lhs.title.isEqual(to: rhs.title) && lhs.rows == rhs.rows
    }

    private static func row(_ label: String, _ value: String) -> WeatherDetailRowUIModel {
        WeatherDetailRowUIModel(
            label: label,
            value: NSAttributedString(
                string: value,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 15),
                    .foregroundColor: UIColor.label
                ]
            )
        )
    }
}
