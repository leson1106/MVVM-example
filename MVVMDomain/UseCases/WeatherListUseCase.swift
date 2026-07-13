import Foundation
import RxSwift

public protocol WeatherListUseCase {
    func fetchList(filter: WeatherListFilter) -> Observable<WeatherListSnapshot>
}

public final class WeatherListUseCaseImpl: WeatherListUseCase {
    private let repository: WeatherRepositoryProtocol
    private let bookmarkStore: BookmarkStoreProtocol
    private let calendar: Calendar
    private let dateProvider: () -> Date

    public init(
        repository: WeatherRepositoryProtocol,
        bookmarkStore: BookmarkStoreProtocol,
        calendar: Calendar = .current,
        dateProvider: @escaping () -> Date = Date.init
    ) {
        self.repository = repository
        self.bookmarkStore = bookmarkStore
        self.calendar = calendar
        self.dateProvider = dateProvider
    }

    public func fetchList(filter: WeatherListFilter) -> Observable<WeatherListSnapshot> {
        switch filter {
        case .bookmarked:
            return fetchBookmarkedOnly()
        case .sevenDays, .thirtyDays:
            guard let dayCount = filter.dayCount else {
                return .just(WeatherListSnapshot(sections: []))
            }
            let range = makeDateRange(dayCount: dayCount)
            return repository.fetchHistoricalRange(startDate: range.start, endDate: range.end)
                .map { [bookmarkStore] days in
                    self.makeSnapshot(from: days, bookmarkStore: bookmarkStore, includeRecent: true)
                }
        }
    }

    private func fetchBookmarkedOnly() -> Observable<WeatherListSnapshot> {
        let bookmarkedIds = bookmarkStore.bookmarkedIds().sorted(by: >)
        guard bookmarkedIds.isEmpty == false else {
            return .just(WeatherListSnapshot(sections: []))
        }
        return repository.fetchHistoricalDates(bookmarkedIds)
            .map { days in
                let sortedDays = days.sorted { $0.id > $1.id }
                let items = sortedDays.map(WeatherListItemUIModel.init(day:))
                let section = WeatherListSection(kind: .bookmarked, title: "Bookmarked", items: items)
                return WeatherListSnapshot(sections: [section])
            }
    }

    private func makeSnapshot(
        from days: [WeatherDay],
        bookmarkStore: BookmarkStoreProtocol,
        includeRecent: Bool
    ) -> WeatherListSnapshot {
        let sortedDays = days.sorted { $0.id > $1.id }
        let bookmarkedIds = bookmarkStore.bookmarkedIds()
        let bookmarkedDays = sortedDays.filter { bookmarkedIds.contains($0.id) }
        let recentDays = includeRecent ? sortedDays.filter { bookmarkedIds.contains($0.id) == false } : []

        var sections: [WeatherListSection] = []
        if bookmarkedDays.isEmpty == false {
            sections.append(
                WeatherListSection(
                    kind: .bookmarked,
                    title: "Bookmarked",
                    items: bookmarkedDays.map(WeatherListItemUIModel.init(day:))
                )
            )
        }
        if recentDays.isEmpty == false {
            sections.append(
                WeatherListSection(
                    kind: .recent,
                    title: "Recent",
                    items: recentDays.map(WeatherListItemUIModel.init(day:))
                )
            )
        }
        return WeatherListSnapshot(sections: sections)
    }

    private func makeDateRange(dayCount: Int) -> (start: String, end: String) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let endDate = dateProvider()
        let startDate = calendar.date(byAdding: .day, value: -(dayCount - 1), to: endDate) ?? endDate
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        let start = formatter.string(from: startDate)
        let end = formatter.string(from: endDate)
        return start <= end ? (start, end) : (end, start)
    }
}
