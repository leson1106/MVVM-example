import MVVMDomain
import RxCocoa
import RxSwift
import UIKit

final class WeatherDetailViewController: UIViewController {
    private let viewModel: WeatherDetailViewModel
    private let customView = WeatherDetailView()
    private let disposeBag = DisposeBag()
    private lazy var bookmarkButton = UIBarButtonItem(
        image: UIImage(systemName: "bookmark"),
        style: .plain,
        target: nil,
        action: nil
    )

    init(viewModel: WeatherDetailViewModel) {
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
        title = "Weather Detail"
        navigationItem.rightBarButtonItem = bookmarkButton
        bindViewModel()
    }

    private func bindViewModel() {
        let input = WeatherDetailViewModel.Input(
            viewDidLoad: Driver.just(()),
            bookmarkTapped: bookmarkButton.rx.tap.asDriver()
        )

        let output = viewModel.transform(input: input)

        output.detail
            .drive(onNext: { [customView] detail in
                customView.render(detail: detail)
                customView.setLoading(false)
            })
            .disposed(by: disposeBag)

        output.isBookmarked
            .drive(onNext: { [bookmarkButton] isBookmarked in
                let imageName = isBookmarked ? "bookmark.fill" : "bookmark"
                bookmarkButton.image = UIImage(systemName: imageName)
            })
            .disposed(by: disposeBag)

        output.errorMessage
            .drive(onNext: { [customView] message in
                customView.setErrorMessage(message)
                customView.setLoading(false)
            })
            .disposed(by: disposeBag)

        customView.setLoading(true)
    }
}
