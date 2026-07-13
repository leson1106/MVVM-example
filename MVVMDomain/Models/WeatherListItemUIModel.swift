import UIKit

public struct WeatherListItemUIModel: Equatable {
    public let id: String
    public let summary: NSAttributedString

    public init(id: String, summary: NSAttributedString) {
        self.id = id
        self.summary = summary
    }

    public init(day: WeatherDay) {
        self.id = day.id
        self.summary = Self.makeSummary(from: day)
    }

    public static func == (lhs: WeatherListItemUIModel, rhs: WeatherListItemUIModel) -> Bool {
        lhs.id == rhs.id && lhs.summary.isEqual(to: rhs.summary)
    }

    private static func makeSummary(from day: WeatherDay) -> NSAttributedString {
        let summary = NSMutableAttributedString()
        summary.append(
            NSAttributedString(
                string: day.displayDate,
                attributes: [
                    .font: UIFont.boldSystemFont(ofSize: 16),
                    .foregroundColor: UIColor.label
                ]
            )
        )
        summary.append(NSAttributedString(string: "\n"))
        summary.append(
            NSAttributedString(
                string: "Avg \(day.averageTemperature)°C  |  \(day.minTemperature)° – \(day.maxTemperature)°",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 14),
                    .foregroundColor: UIColor.secondaryLabel
                ]
            )
        )
        summary.append(NSAttributedString(string: "\n"))
        summary.append(
            NSAttributedString(
                string: "UV \(day.uvIndex)  •  Sun \(day.sunHour)h",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 13),
                    .foregroundColor: UIColor.tertiaryLabel
                ]
            )
        )
        return summary
    }
}
