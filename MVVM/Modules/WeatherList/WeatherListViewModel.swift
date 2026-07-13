import MVVMDomain
import RxCocoa
import RxSwift

final class WeatherListViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad: Driver<Void>
        let viewWillAppear: Driver<Void>
        let filterSelected: Driver<WeatherListFilter>
        let itemSelected: Driver<String>
    }

    struct Output {
        let sections: Driver<[WeatherListSection]>
        let isLoading: Driver<Bool>
        let errorMessage: Driver<String?>
        let selectedFilter: Driver<WeatherListFilter>
        let navigation: Driver<Void>
    }

    private struct ListState {
        let sections: [WeatherListSection]
        let errorMessage: String?
    }

    private let useCase: WeatherListUseCase
    private let navigator: WeatherListNavigator
    private let initialFilter: WeatherListFilter

    init(
        useCase: WeatherListUseCase,
        navigator: WeatherListNavigator,
        initialFilter: WeatherListFilter = .sevenDays
    ) {
        self.useCase = useCase
        self.navigator = navigator
        self.initialFilter = initialFilter
    }

    func transform(input: Input) -> Output {
        let filterRelay = BehaviorRelay<WeatherListFilter>(value: initialFilter)
        let loadingRelay = BehaviorRelay<Bool>(value: false)

        let filterUpdates = input.filterSelected
            .do(onNext: { filterRelay.accept($0) })

        let refreshTrigger = Driver.merge(
            input.viewDidLoad,
            input.viewWillAppear,
            filterUpdates.map { _ in () }
        )

        let listState = refreshTrigger
            .withLatestFrom(filterRelay.asDriver())
            .flatMapLatest { [useCase, loadingRelay] filter -> Driver<ListState> in
                loadingRelay.accept(true)
                return useCase.fetchList(filter: filter)
                    .map { ListState(sections: $0.sections, errorMessage: nil) }
                    .catch { error in
                        Observable.just(ListState(sections: [], errorMessage: error.localizedDescription))
                    }
                    .do(onNext: { _ in loadingRelay.accept(false) })
                    .asDriver(onErrorJustReturn: ListState(sections: [], errorMessage: nil))
            }

        let navigation = input.itemSelected
            .do(onNext: { [navigator] date in
                navigator.showDetail(date: date)
            })
            .map { _ in () }

        return Output(
            sections: listState.map { $0.sections },
            isLoading: loadingRelay.asDriver(),
            errorMessage: listState.map { $0.errorMessage },
            selectedFilter: filterRelay.asDriver(),
            navigation: navigation
        )
    }
}
