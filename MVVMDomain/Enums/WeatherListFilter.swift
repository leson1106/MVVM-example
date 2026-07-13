import Foundation

public enum WeatherListFilter: Equatable, CaseIterable {
    case sevenDays
    case thirtyDays
    case bookmarked

    public var dayCount: Int? {
        switch self {
        case .sevenDays:
            return 7
        case .thirtyDays:
            return 30
        case .bookmarked:
            return nil
        }
    }
}
