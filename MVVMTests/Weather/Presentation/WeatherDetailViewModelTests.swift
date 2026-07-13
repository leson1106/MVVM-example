import MVVMDomain
import MVVMNetwork
import RxCocoa
import RxSwift
import XCTest
@testable import MVVM

@MainActor
final class WeatherDetailViewModelTests: XCTestCase {
    private var useCaseMock: WeatherDetailUseCaseMock!
    private var navigatorMock: WeatherDetailNavigatorMock!
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        useCaseMock = WeatherDetailUseCaseMock()
        navigatorMock = WeatherDetailNavigatorMock()
        disposeBag = DisposeBag()
    }

    func test_transform_viewDidLoad_emitsDetailAndBookmarkState() {
        // given
        let detail = WeatherDetailUIModel(day: WeatherTestFixtures.makeDay())
        useCaseMock.isBookmarkedReturnValue = true
        useCaseMock.fetchDetailReturnValue = .just(detail)
        let viewModel = WeatherDetailViewModel(date: "2024-03-18", useCase: useCaseMock, navigator: navigatorMock)
        let viewDidLoad = PublishSubject<Void>()
        let input = WeatherDetailViewModel.Input(
            viewDidLoad: viewDidLoad.asDriver(onErrorJustReturn: ()),
            bookmarkTapped: .empty()
        )
        let output = viewModel.transform(input: input)
        let detailExp = expectation(description: "detail emitted")
        let bookmarkExp = expectation(description: "bookmark emitted")

        output.detail
            .drive(onNext: { model in
                XCTAssertNotNil(model)
                detailExp.fulfill()
            })
            .disposed(by: disposeBag)

        output.isBookmarked
            .drive(onNext: { isBookmarked in
                XCTAssertTrue(isBookmarked)
                bookmarkExp.fulfill()
            })
            .disposed(by: disposeBag)

        // when
        viewDidLoad.onNext(())
        wait(for: [detailExp, bookmarkExp], timeout: 2.0)

        // then
        XCTAssertTrue(useCaseMock.fetchDetailCalled)
        XCTAssertEqual(useCaseMock.fetchDetailReceivedDate, "2024-03-18")
    }

    func test_transform_bookmarkTapped_whenNotBookmarked_bookmarksImmediately() {
        // given
        useCaseMock.isBookmarkedReturnValue = false
        useCaseMock.fetchDetailReturnValue = .just(WeatherDetailUIModel(day: WeatherTestFixtures.makeDay()))
        let viewModel = WeatherDetailViewModel(date: "2024-03-18", useCase: useCaseMock, navigator: navigatorMock)
        let bookmarkTapped = PublishSubject<Void>()
        let input = WeatherDetailViewModel.Input(
            viewDidLoad: Driver.just(()),
            bookmarkTapped: bookmarkTapped.asDriver(onErrorJustReturn: ())
        )
        let output = viewModel.transform(input: input)
        output.detail.drive(onNext: { _ in }).disposed(by: disposeBag)

        var bookmarkStates: [Bool] = []
        output.isBookmarked
            .drive(onNext: { bookmarkStates.append($0) })
            .disposed(by: disposeBag)

        // when
        bookmarkTapped.onNext(())

        let exp = expectation(description: "settle")
        DispatchQueue.main.async { exp.fulfill() }
        wait(for: [exp], timeout: 2.0)

        // then
        XCTAssertFalse(navigatorMock.confirmUnbookmarkCalled)
        XCTAssertTrue(useCaseMock.setBookmarkedCalled)
        XCTAssertEqual(useCaseMock.setBookmarkedReceivedDate, "2024-03-18")
        XCTAssertEqual(useCaseMock.setBookmarkedReceivedValue, true)
        XCTAssertEqual(bookmarkStates, [false, true])
    }

    func test_transform_bookmarkTapped_whenBookmarked_confirmsThenUnbookmarks() {
        // given
        useCaseMock.isBookmarkedReturnValue = true
        useCaseMock.fetchDetailReturnValue = .just(WeatherDetailUIModel(day: WeatherTestFixtures.makeDay()))
        navigatorMock.confirmUnbookmarkReturnValue = .just(true)
        let viewModel = WeatherDetailViewModel(date: "2024-03-18", useCase: useCaseMock, navigator: navigatorMock)
        let bookmarkTapped = PublishSubject<Void>()
        let input = WeatherDetailViewModel.Input(
            viewDidLoad: Driver.just(()),
            bookmarkTapped: bookmarkTapped.asDriver(onErrorJustReturn: ())
        )
        let output = viewModel.transform(input: input)
        output.detail.drive(onNext: { _ in }).disposed(by: disposeBag)

        var bookmarkStates: [Bool] = []
        output.isBookmarked
            .drive(onNext: { bookmarkStates.append($0) })
            .disposed(by: disposeBag)

        // when
        bookmarkTapped.onNext(())

        let exp = expectation(description: "settle")
        DispatchQueue.main.async { exp.fulfill() }
        wait(for: [exp], timeout: 2.0)

        // then
        XCTAssertTrue(navigatorMock.confirmUnbookmarkCalled)
        XCTAssertTrue(useCaseMock.setBookmarkedCalled)
        XCTAssertEqual(useCaseMock.setBookmarkedReceivedValue, false)
        XCTAssertEqual(bookmarkStates, [true, false])
    }

    func test_transform_bookmarkTapped_whenBookmarked_cancelKeepsBookmark() {
        // given
        useCaseMock.isBookmarkedReturnValue = true
        useCaseMock.fetchDetailReturnValue = .just(WeatherDetailUIModel(day: WeatherTestFixtures.makeDay()))
        navigatorMock.confirmUnbookmarkReturnValue = .just(false)
        let viewModel = WeatherDetailViewModel(date: "2024-03-18", useCase: useCaseMock, navigator: navigatorMock)
        let bookmarkTapped = PublishSubject<Void>()
        let input = WeatherDetailViewModel.Input(
            viewDidLoad: Driver.just(()),
            bookmarkTapped: bookmarkTapped.asDriver(onErrorJustReturn: ())
        )
        let output = viewModel.transform(input: input)
        output.detail.drive(onNext: { _ in }).disposed(by: disposeBag)

        var bookmarkStates: [Bool] = []
        output.isBookmarked
            .drive(onNext: { bookmarkStates.append($0) })
            .disposed(by: disposeBag)

        // when
        bookmarkTapped.onNext(())

        let exp = expectation(description: "settle")
        DispatchQueue.main.async { exp.fulfill() }
        wait(for: [exp], timeout: 2.0)

        // then
        XCTAssertTrue(navigatorMock.confirmUnbookmarkCalled)
        XCTAssertFalse(useCaseMock.setBookmarkedCalled)
        XCTAssertEqual(bookmarkStates, [true])
    }

    func test_transform_fetchFailure_emitsErrorMessage() {
        // given
        useCaseMock.fetchDetailReturnValue = .error(WeatherAPIError.api(message: "Detail failed"))
        let viewModel = WeatherDetailViewModel(date: "2024-03-18", useCase: useCaseMock, navigator: navigatorMock)
        let input = WeatherDetailViewModel.Input(
            viewDidLoad: Driver.just(()),
            bookmarkTapped: .empty()
        )
        let output = viewModel.transform(input: input)
        let exp = expectation(description: "error emitted")

        output.errorMessage
            .drive(onNext: { message in
                XCTAssertEqual(message, "Detail failed")
                exp.fulfill()
            })
            .disposed(by: disposeBag)

        wait(for: [exp], timeout: 2.0)
    }
}
