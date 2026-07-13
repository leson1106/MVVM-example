import MVVMDomain
import RxSwift
import XCTest
@testable import MVVMNetwork

final class FailingWeatherRepositoryTests: XCTestCase {
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
    }

    func test_fetchHistoricalRange_returnsMissingKeyError() {
        // given
        let repository = FailingWeatherRepository()
        let exp = expectation(description: "error")
        var receivedError: WeatherAPIError?

        // when
        repository.fetchHistoricalRange(startDate: "2024-03-01", endDate: "2024-03-07")
            .subscribe(onError: { error in
                receivedError = error as? WeatherAPIError
                exp.fulfill()
            })
            .disposed(by: disposeBag)
        wait(for: [exp], timeout: 2.0)

        // then
        XCTAssertEqual(receivedError, .missingAccessKey)
    }
}
