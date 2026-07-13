import MVVMDomain
import RxCocoa
import RxSwift
import UIKit

final class WeatherListViewController: UIViewController {
    private let viewModel: WeatherListViewModel
    private let customView = WeatherListView()
    private let disposeBag = DisposeBag()
    private let itemSelectedSubject = PublishSubject<String>()
    private let viewWillAppearSubject = PublishSubject<Void>()

    init(viewModel: WeatherListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func loadView() {
        view = customView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Hanoi Weather"
        bindViewModel()
        customView.onItemSelected = { [itemSelectedSubject] id in
            itemSelectedSubject.onNext(id)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearSubject.onNext(())
    }

    private func bindViewModel() {
        let filterSelected = customView.filterControl.rx.selectedSegmentIndex
            .skip(1)
            .compactMap { index -> WeatherListFilter? in
                switch index {
                case 0: return .sevenDays
                case 1: return .thirtyDays
                case 2: return .bookmarked
                default: return nil
                }
            }
            .asDriver(onErrorJustReturn: .sevenDays)

        let input = WeatherListViewModel.Input(
            viewDidLoad: Driver.just(()),
            viewWillAppear: viewWillAppearSubject.asDriver(onErrorJustReturn: ()),
            filterSelected: filterSelected,
            itemSelected: itemSelectedSubject.asDriver(onErrorJustReturn: "")
        )

        let output = viewModel.transform(input: input)

        output.sections
            .drive(onNext: { [customView] sections in
                customView.render(sections: sections)
            })
            .disposed(by: disposeBag)

        output.isLoading
            .drive(onNext: { [customView] isLoading in
                customView.setLoading(isLoading)
            })
            .disposed(by: disposeBag)

        output.errorMessage
            .drive(onNext: { [customView] message in
                customView.setErrorMessage(message)
            })
            .disposed(by: disposeBag)

        output.selectedFilter
            .drive(onNext: { [customView] filter in
                customView.setSelectedFilter(filter)
            })
            .disposed(by: disposeBag)

        output.navigation
            .drive()
            .disposed(by: disposeBag)
    }
}
