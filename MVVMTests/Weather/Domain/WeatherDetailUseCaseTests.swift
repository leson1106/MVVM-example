import MVVMDomain
import RxSwift
import XCTest

final class WeatherDetailUseCaseTests: XCTestCase {
    private var repositoryMock: WeatherRepositoryMock!
    private var bookmarkStoreMock: BookmarkStoreMock!
    private var useCase: WeatherDetailUseCaseImpl!
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        repositoryMock = WeatherRepositoryMock()
        bookmarkStoreMock = BookmarkStoreMock()
        useCase = WeatherDetailUseCaseImpl(repository: repositoryMock, bookmarkStore: bookmarkStoreMock)
        disposeBag = DisposeBag()
    }

    func test_fetchDetail_callsRepositoryWithDateAndHourly() {
        // given
        let day = WeatherTestFixtures.makeDay()
        repositoryMock.fetchHistoricalDayReturnValue = .just(day)
        let exp = expectation(description: "detail fetched")
        var detail: WeatherDetailUIModel?

        // when
        useCase.fetchDetail(date: "2024-03-18")
            .subscribe(onNext: { value in
                detail = value
                exp.fulfill()
             })
            .disposed(by: disposeBag)
        wait(for: [exp], timeout: 2.0)

        // then
        XCTAssertTrue(repositoryMock.fetchHistoricalDayCalled)
        XCTAssertEqual(repositoryMock.fetchHistoricalDayReceivedDate, "2024-03-18")
        XCTAssertEqual(repositoryMock.fetchHistoricalDayReceivedIncludeHourly, true)
        XCTAssertEqual(detail?.rows.first?.label, "Location")
    }

    func test_setBookmarked_true_updatesBookmarkStore() {
        // when
        useCase.setBookmarked(date: "2024-03-18", bookmarked: true)

        // then
        XCTAssertTrue(bookmarkStoreMock.setBookmarkedCalled)
        XCTAssertEqual(bookmarkStoreMock.setBookmarkedReceivedId, "2024-03-18")
        XCTAssertEqual(bookmarkStoreMock.setBookmarkedReceivedValue, true)
    }

    func test_setBookmarked_false_removesBookmark() {
        // when
        useCase.setBookmarked(date: "2024-03-18", bookmarked: false)

        // then
        XCTAssertEqual(bookmarkStoreMock.setBookmarkedReceivedValue, false)
    }

    func test_isBookmarked_readsBookmarkStore() {
        // given
        bookmarkStoreMock.bookmarkedIdsReturnValue = ["2024-03-18"]

        // then
        XCTAssertTrue(useCase.isBookmarked(date: "2024-03-18"))
        XCTAssertFalse(useCase.isBookmarked(date: "2024-03-17"))
    }
}
