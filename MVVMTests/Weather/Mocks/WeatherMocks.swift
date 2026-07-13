import Foundation
import MVVMDomain
import RxSwift
@testable import MVVM

final class WeatherRepositoryMock: WeatherRepositoryProtocol {
    var fetchHistoricalRangeCalled = false
    var fetchHistoricalRangeReceivedStart: String?
    var fetchHistoricalRangeReceivedEnd: String?
    var fetchHistoricalRangeReturnValue: Observable<[WeatherDay]> = .just([])

    var fetchHistoricalDatesCalled = false
    var fetchHistoricalDatesReceivedDates: [String]?
    var fetchHistoricalDatesReturnValue: Observable<[WeatherDay]> = .just([])

    var fetchHistoricalDayCalled = false
    var fetchHistoricalDayReceivedDate: String?
    var fetchHistoricalDayReceivedIncludeHourly: Bool?
    var fetchHistoricalDayReturnValue: Observable<WeatherDay> = .never()

    func fetchHistoricalRange(startDate: String, endDate: String) -> Observable<[WeatherDay]> {
        fetchHistoricalRangeCalled = true
        fetchHistoricalRangeReceivedStart = startDate
        fetchHistoricalRangeReceivedEnd = endDate
        return fetchHistoricalRangeReturnValue
    }

    func fetchHistoricalDates(_ dates: [String]) -> Observable<[WeatherDay]> {
        fetchHistoricalDatesCalled = true
        fetchHistoricalDatesReceivedDates = dates
        return fetchHistoricalDatesReturnValue
    }

    func fetchHistoricalDay(date: String, includeHourly: Bool) -> Observable<WeatherDay> {
        fetchHistoricalDayCalled = true
        fetchHistoricalDayReceivedDate = date
        fetchHistoricalDayReceivedIncludeHourly = includeHourly
        return fetchHistoricalDayReturnValue
    }
}

final class BookmarkStoreMock: BookmarkStoreProtocol {
    var bookmarkedIdsReturnValue: Set<String> = []
    var setBookmarkedCalled = false
    var setBookmarkedReceivedId: String?
    var setBookmarkedReceivedValue: Bool?

    func bookmarkedIds() -> Set<String> {
        bookmarkedIdsReturnValue
    }

    func isBookmarked(id: String) -> Bool {
        bookmarkedIdsReturnValue.contains(id)
    }

    func setBookmarked(id: String, bookmarked: Bool) {
        setBookmarkedCalled = true
        setBookmarkedReceivedId = id
        setBookmarkedReceivedValue = bookmarked
        if bookmarked {
            bookmarkedIdsReturnValue.insert(id)
        } else {
            bookmarkedIdsReturnValue.remove(id)
        }
    }
}

final class WeatherListUseCaseMock: WeatherListUseCase {
    var fetchListCalled = false
    var fetchListReceivedFilter: WeatherListFilter?
    var fetchListReturnValue: Observable<WeatherListSnapshot> = .just(WeatherListSnapshot(sections: []))

    func fetchList(filter: WeatherListFilter) -> Observable<WeatherListSnapshot> {
        fetchListCalled = true
        fetchListReceivedFilter = filter
        return fetchListReturnValue
    }
}

final class WeatherDetailUseCaseMock: WeatherDetailUseCase {
    var fetchDetailCalled = false
    var fetchDetailReceivedDate: String?
    var fetchDetailReturnValue: Observable<WeatherDetailUIModel> = .never()

    var isBookmarkedReturnValue = false
    var setBookmarkedCalled = false
    var setBookmarkedReceivedDate: String?
    var setBookmarkedReceivedValue: Bool?

    func fetchDetail(date: String) -> Observable<WeatherDetailUIModel> {
        fetchDetailCalled = true
        fetchDetailReceivedDate = date
        return fetchDetailReturnValue
    }

    func isBookmarked(date: String) -> Bool {
        isBookmarkedReturnValue
    }

    func setBookmarked(date: String, bookmarked: Bool) {
        setBookmarkedCalled = true
        setBookmarkedReceivedDate = date
        setBookmarkedReceivedValue = bookmarked
        isBookmarkedReturnValue = bookmarked
    }
}

final class WeatherListNavigatorMock: WeatherListNavigator {
    var showDetailCalled = false
    var showDetailReceivedDate: String?
    var onShowDetail: (() -> Void)?

    func showDetail(date: String) {
        showDetailCalled = true
        showDetailReceivedDate = date
        onShowDetail?()
    }
}

final class WeatherDetailNavigatorMock: WeatherDetailNavigator {
    var confirmUnbookmarkCalled = false
    var confirmUnbookmarkReturnValue: Observable<Bool> = .just(true)

    func confirmUnbookmark() -> Observable<Bool> {
        confirmUnbookmarkCalled = true
        return confirmUnbookmarkReturnValue
    }
}

enum WeatherTestFixtures {
    static func makeDay(
        id: String = "2024-03-18",
        locationName: String = "Hanoi",
        hourly: [WeatherHourly] = []
    ) -> WeatherDay {
        WeatherDay(
            id: id,
            locationName: locationName,
            region: "Hanoi",
            country: "Vietnam",
            displayDate: "Mar 18, 2024",
            minTemperature: "20",
            maxTemperature: "28",
            averageTemperature: "24",
            totalSnow: "0",
            sunHour: "8",
            uvIndex: "5",
            astro: WeatherAstro(
                sunrise: "06:00 AM",
                sunset: "06:30 PM",
                moonrise: "07:00 AM",
                moonset: "07:30 PM",
                moonPhase: "Full Moon",
                moonIllumination: "100"
            ),
            hourly: hourly
        )
    }
}
