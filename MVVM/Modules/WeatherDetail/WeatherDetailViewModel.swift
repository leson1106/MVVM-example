import MVVMDomain
import RxCocoa
import RxSwift

final class WeatherDetailViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad: Driver<Void>
        let bookmarkTapped: Driver<Void>
    }

    struct Output {
        let detail: Driver<WeatherDetailUIModel?>
        let isBookmarked: Driver<Bool>
        let errorMessage: Driver<String?>
    }

    private struct DetailState {
        let detail: WeatherDetailUIModel?
        let errorMessage: String?
    }

    private let date: String
    private let useCase: WeatherDetailUseCase
    private let navigator: WeatherDetailNavigator

    init(date: String, useCase: WeatherDetailUseCase, navigator: WeatherDetailNavigator) {
        self.date = date
        self.useCase = useCase
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {
        let bookmarkRelay = BehaviorRelay<Bool>(value: useCase.isBookmarked(date: date))

        let detailState = input.viewDidLoad
            .flatMapLatest { [useCase, date] _ -> Driver<DetailState> in
                useCase.fetchDetail(date: date)
                    .map { DetailState(detail: $0, errorMessage: nil) }
                    .catch { error in
                        Observable.just(DetailState(detail: nil, errorMessage: error.localizedDescription))
                    }
                    .asDriver(onErrorJustReturn: DetailState(detail: nil, errorMessage: nil))
            }

        let bookmarkUpdates = input.bookmarkTapped
            .withLatestFrom(bookmarkRelay.asDriver())
            .flatMapLatest { [useCase, date, navigator] isBookmarked -> Driver<Bool> in
                if isBookmarked {
                    return navigator.confirmUnbookmark()
                        .flatMap { confirmed -> Observable<Bool> in
                            guard confirmed else { return .empty() }
                            useCase.setBookmarked(date: date, bookmarked: false)
                            return .just(false)
                        }
                        .asDriver(onErrorDriveWith: .empty())
                }

                useCase.setBookmarked(date: date, bookmarked: true)
                return Driver.just(true)
            }

        let isBookmarked = bookmarkUpdates
            .startWith(bookmarkRelay.value)
            .do(onNext: bookmarkRelay.accept)

        return Output(
            detail: detailState.map { $0.detail },
            isBookmarked: isBookmarked,
            errorMessage: detailState.map { $0.errorMessage }
        )
    }
}
