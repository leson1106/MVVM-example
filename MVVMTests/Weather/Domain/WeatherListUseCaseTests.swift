import MVVMDomain
import RxSwift
import XCTest

final class WeatherListUseCaseTests: XCTestCase {
    private var repositoryMock: WeatherRepositoryMock!
    private var bookmarkStoreMock: BookmarkStoreMock!
    private var useCase: WeatherListUseCaseImpl!
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        repositoryMock = WeatherRepositoryMock()
        bookmarkStoreMock = BookmarkStoreMock()
        disposeBag = DisposeBag()
        let calendar = Calendar(identifier: .gregorian)
        var utcCalendar = calendar
        utcCalendar.timeZone = TimeZone(secondsFromGMT: 0)!
        var components = DateComponents()
        components.year = 2024
        components.month = 3
        components.day = 18
        let fixedDate = utcCalendar.date(from: components)!
        useCase = WeatherListUseCaseImpl(
            repository: repositoryMock,
            bookmarkStore: bookmarkStoreMock,
            calendar: utcCalendar,
            dateProvider: { fixedDate }
        )
    }

    func test_fetchList_sevenDays_callsRepositoryWithSevenDayRange() {
        // given
        repositoryMock.fetchHistoricalRangeReturnValue = .just([WeatherTestFixtures.makeDay()])
        let exp = expectation(description: "fetch completed")

        // when
        useCase.fetchList(filter: .sevenDays)
            .subscribe(onNext: { _ in exp.fulfill()  })
            .disposed(by: disposeBag)
        wait(for: [exp], timeout: 2.0)

        // then
        XCTAssertTrue(repositoryMock.fetchHistoricalRangeCalled)
        XCTAssertEqual(repositoryMock.fetchHistoricalRangeReceivedStart, "2024-03-12")
        XCTAssertEqual(repositoryMock.fetchHistoricalRangeReceivedEnd, "2024-03-18")
    }

    func test_fetchList_thirtyDays_callsRepositoryWithThirtyDayRange() {
        // given
        repositoryMock.fetchHistoricalRangeReturnValue = .just([WeatherTestFixtures.makeDay()])
        let exp = expectation(description: "fetch completed")

        // when
        useCase.fetchList(filter: .thirtyDays)
            .subscribe(onNext: { _ in exp.fulfill()  })
            .disposed(by: disposeBag)
        wait(for: [exp], timeout: 2.0)

        // then
        XCTAssertTrue(repositoryMock.fetchHistoricalRangeCalled)
        XCTAssertEqual(repositoryMock.fetchHistoricalRangeReceivedStart, "2024-02-18")
        XCTAssertEqual(repositoryMock.fetchHistoricalRangeReceivedEnd, "2024-03-18")
    }

    func test_fetchList_sevenDays_splitsBookmarkedIntoTopSection() {
        // given
        let bookmarkedDay = WeatherTestFixtures.makeDay(id: "2024-03-18")
        let recentDay = WeatherTestFixtures.makeDay(id: "2024-03-17")
        bookmarkStoreMock.bookmarkedIdsReturnValue = ["2024-03-18"]
        repositoryMock.fetchHistoricalRangeReturnValue = .just([recentDay, bookmarkedDay])
        let exp = expectation(description: "fetch completed")
        var snapshot: WeatherListSnapshot?

        // when
        useCase.fetchList(filter: .sevenDays)
            .subscribe(onNext: { value in
                snapshot = value
                exp.fulfill()
             })
            .disposed(by: disposeBag)
        wait(for: [exp], timeout: 2.0)

        // then
        XCTAssertEqual(snapshot?.sections.count, 2)
        XCTAssertEqual(snapshot?.sections.first?.kind, .bookmarked)
        XCTAssertEqual(snapshot?.sections.first?.items.first?.id, "2024-03-18")
        XCTAssertEqual(snapshot?.sections.last?.kind, .recent)
        XCTAssertEqual(snapshot?.sections.last?.items.first?.id, "2024-03-17")
    }

    func test_fetchList_bookmarkedFilter_returnsOnlyBookmarkedSection() {
        // given
        bookmarkStoreMock.bookmarkedIdsReturnValue = ["2024-03-18"]
        repositoryMock.fetchHistoricalDatesReturnValue = .just([WeatherTestFixtures.makeDay(id: "2024-03-18")])
        let exp = expectation(description: "fetch completed")
        var snapshot: WeatherListSnapshot?

        // when
        useCase.fetchList(filter: .bookmarked)
            .subscribe(onNext: { value in
                snapshot = value
                exp.fulfill()
             })
            .disposed(by: disposeBag)
        wait(for: [exp], timeout: 2.0)

        // then
        XCTAssertTrue(repositoryMock.fetchHistoricalDatesCalled)
        XCTAssertEqual(repositoryMock.fetchHistoricalDatesReceivedDates, ["2024-03-18"])
        XCTAssertEqual(snapshot?.sections.count, 1)
        XCTAssertEqual(snapshot?.sections.first?.kind, .bookmarked)
    }

    func test_fetchList_bookmarkedFilterWithNoBookmarks_returnsEmptySnapshot() {
        // given
        let exp = expectation(description: "fetch completed")
        var snapshot: WeatherListSnapshot?

        // when
        useCase.fetchList(filter: .bookmarked)
            .subscribe(onNext: { value in
                snapshot = value
                exp.fulfill()
             })
            .disposed(by: disposeBag)
        wait(for: [exp], timeout: 2.0)

        // then
        XCTAssertFalse(repositoryMock.fetchHistoricalDatesCalled)
        XCTAssertEqual(snapshot?.sections, [])
    }

    func test_fetchList_repositoryError_propagatesError() {
        // given
        repositoryMock.fetchHistoricalRangeReturnValue = .error(NSError(domain: "test", code: 1))
        let exp = expectation(description: "error propagated")
        var receivedError: Error?

        // when
        useCase.fetchList(filter: .sevenDays)
            .subscribe(onError: { error in
                receivedError = error
                exp.fulfill()
            })
            .disposed(by: disposeBag)
        wait(for: [exp], timeout: 2.0)

        // then
        XCTAssertNotNil(receivedError)
    }

    func test_fetchList_sevenDays_withNoDays_returnsEmptySections() {
        // given
        repositoryMock.fetchHistoricalRangeReturnValue = .just([])
        let exp = expectation(description: "fetch completed")
        var snapshot: WeatherListSnapshot?

        // when
        useCase.fetchList(filter: .sevenDays)
            .subscribe(onNext: { value in
                snapshot = value
                exp.fulfill()
             })
            .disposed(by: disposeBag)
        wait(for: [exp], timeout: 2.0)

        // then
        XCTAssertEqual(snapshot?.sections, [])
    }
}
