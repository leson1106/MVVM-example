import Foundation
import RxSwift

public protocol WeatherDetailUseCase {
    func fetchDetail(date: String) -> Observable<WeatherDetailUIModel>
    func isBookmarked(date: String) -> Bool
    func setBookmarked(date: String, bookmarked: Bool)
}

public final class WeatherDetailUseCaseImpl: WeatherDetailUseCase {
    private let repository: WeatherRepositoryProtocol
    private let bookmarkStore: BookmarkStoreProtocol

    public init(repository: WeatherRepositoryProtocol, bookmarkStore: BookmarkStoreProtocol) {
        self.repository = repository
        self.bookmarkStore = bookmarkStore
    }

    public func fetchDetail(date: String) -> Observable<WeatherDetailUIModel> {
        repository.fetchHistoricalDay(date: date, includeHourly: true)
            .map(WeatherDetailUIModel.init(day:))
    }

    public func isBookmarked(date: String) -> Bool {
        bookmarkStore.isBookmarked(id: date)
    }

    public func setBookmarked(date: String, bookmarked: Bool) {
        bookmarkStore.setBookmarked(id: date, bookmarked: bookmarked)
    }
}
