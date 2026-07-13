import MVVMDomain
import MVVMNetwork
import RxCocoa
import RxSwift
import XCTest
@testable import MVVM

@MainActor
final class WeatherListViewModelTests: XCTestCase {
    private var useCaseMock: WeatherListUseCaseMock!
    private var navigatorMock: WeatherListNavigatorMock!
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        useCaseMock = WeatherListUseCaseMock()
        navigatorMock = WeatherListNavigatorMock()
        disposeBag = DisposeBag()
    }

    func test_transform_viewDidLoad_emitsSectionsWithDefaultFilter() {
        // given
        let expectedSection = WeatherListSection(
            kind: .recent,
            title: "Recent",
            items: [WeatherListItemUIModel(day: WeatherTestFixtures.makeDay())]
        )
        useCaseMock.fetchListReturnValue = .just(WeatherListSnapshot(sections: [expectedSection]))
        let viewModel = WeatherListViewModel(useCase: useCaseMock, navigator: navigatorMock)
        let viewDidLoad = PublishSubject<Void>()
        let input = makeInput(viewDidLoad: viewDidLoad.asDriver(onErrorJustReturn: ()))

        let output = viewModel.transform(input: input)
        let exp = expectation(description: "sections emitted")

        output.sections
            .drive(onNext: { sections in
                XCTAssertEqual(sections.count, 1)
                XCTAssertEqual(sections.first?.items.first?.id, "2024-03-18")
                exp.fulfill()
            })
            .disposed(by: disposeBag)

        // when
        viewDidLoad.onNext(())
        wait(for: [exp], timeout: 2.0)

        // then
        XCTAssertTrue(useCaseMock.fetchListCalled)
        XCTAssertEqual(useCaseMock.fetchListReceivedFilter, .sevenDays)
    }

    func test_transform_filterSelected_thirtyDays_refetches() {
        // given
        useCaseMock.fetchListReturnValue = .just(WeatherListSnapshot(sections: []))
        let viewModel = WeatherListViewModel(useCase: useCaseMock, navigator: navigatorMock)
        let filterSelected = PublishSubject<WeatherListFilter>()
        let input = makeInput(filterSelected: filterSelected.asDriver(onErrorJustReturn: .sevenDays))
        let output = viewModel.transform(input: input)
        output.sections.drive(onNext: { _ in }).disposed(by: disposeBag)

        // when
        filterSelected.onNext(.thirtyDays)

        // then
        let exp = expectation(description: "filter applied")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(self.useCaseMock.fetchListReceivedFilter, .thirtyDays)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }

    func test_transform_itemSelected_navigatesToDetail() {
        // given
        let viewModel = WeatherListViewModel(useCase: useCaseMock, navigator: navigatorMock)
        let itemSelected = PublishSubject<String>()
        let input = makeInput(itemSelected: itemSelected.asDriver(onErrorJustReturn: ""))
        let output = viewModel.transform(input: input)
        let exp = expectation(description: "navigator called")
        navigatorMock.onShowDetail = { exp.fulfill() }
        output.navigation.drive(onNext: { _ in }).disposed(by: disposeBag)

        // when
        itemSelected.onNext("2024-03-18")
        wait(for: [exp], timeout: 2.0)

        // then
        XCTAssertTrue(navigatorMock.showDetailCalled)
        XCTAssertEqual(navigatorMock.showDetailReceivedDate, "2024-03-18")
    }

    func test_transform_viewWillAppear_refreshesList() {
        // given
        useCaseMock.fetchListReturnValue = .just(WeatherListSnapshot(sections: []))
        let viewModel = WeatherListViewModel(useCase: useCaseMock, navigator: navigatorMock)
        let viewWillAppear = PublishSubject<Void>()
        let input = makeInput(viewWillAppear: viewWillAppear.asDriver(onErrorJustReturn: ()))
        let output = viewModel.transform(input: input)
        output.sections.drive(onNext: { _ in }).disposed(by: disposeBag)

        // when
        viewWillAppear.onNext(())

        // then
        let exp = expectation(description: "refresh called")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertTrue(self.useCaseMock.fetchListCalled)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }

    func test_transform_repositoryError_emitsErrorMessage() {
        // given
        useCaseMock.fetchListReturnValue = .error(WeatherAPIError.api(message: "Network down"))
        let viewModel = WeatherListViewModel(useCase: useCaseMock, navigator: navigatorMock)
        let viewDidLoad = PublishSubject<Void>()
        let input = makeInput(viewDidLoad: viewDidLoad.asDriver(onErrorJustReturn: ()))
        let output = viewModel.transform(input: input)
        let exp = expectation(description: "error emitted")

        output.errorMessage
            .drive(onNext: { message in
                XCTAssertEqual(message, "Network down")
                exp.fulfill()
            })
            .disposed(by: disposeBag)

        // when
        viewDidLoad.onNext(())
        wait(for: [exp], timeout: 2.0)
    }

    private func makeInput(
        viewDidLoad: Driver<Void> = .empty(),
        viewWillAppear: Driver<Void> = .empty(),
        filterSelected: Driver<WeatherListFilter> = .empty(),
        itemSelected: Driver<String> = .empty()
    ) -> WeatherListViewModel.Input {
        WeatherListViewModel.Input(
            viewDidLoad: viewDidLoad,
            viewWillAppear: viewWillAppear,
            filterSelected: filterSelected,
            itemSelected: itemSelected
        )
    }
}
