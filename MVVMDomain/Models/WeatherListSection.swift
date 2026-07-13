import Foundation

public enum WeatherListSectionKind: Equatable {
    case bookmarked
    case recent
}

public struct WeatherListSection: Equatable {
    public let kind: WeatherListSectionKind
    public let title: String
    public let items: [WeatherListItemUIModel]

    public init(kind: WeatherListSectionKind, title: String, items: [WeatherListItemUIModel]) {
        self.kind = kind
        self.title = title
        self.items = items
    }
}

public struct WeatherListSnapshot: Equatable {
    public let sections: [WeatherListSection]

    public init(sections: [WeatherListSection]) {
        self.sections = sections
    }
}
