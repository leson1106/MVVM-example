import MVVMDomain
import RxSwift
import UIKit

protocol WeatherDetailNavigator {
    func confirmUnbookmark() -> Observable<Bool>
}

final class WeatherDetailNavigatorImpl: WeatherDetailNavigator {
    private weak var viewController: UIViewController?

    init() {}

    func attach(viewController: UIViewController) {
        self.viewController = viewController
    }

    func confirmUnbookmark() -> Observable<Bool> {
        Observable.create { [weak self] observer in
            guard let viewController = self?.viewController else {
                observer.onNext(false)
                observer.onCompleted()
                return Disposables.create()
            }

            let alert = UIAlertController(
                title: "Remove Bookmark",
                message: "Are you sure you want to remove this day from bookmarks?",
                preferredStyle: .alert
            )
            alert.addAction(
                UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    observer.onNext(false)
                    observer.onCompleted()
                }
            )
            alert.addAction(
                UIAlertAction(title: "Remove", style: .destructive) { _ in
                    observer.onNext(true)
                    observer.onCompleted()
                }
            )
            viewController.present(alert, animated: true)

            return Disposables.create {
                alert.dismiss(animated: false)
            }
        }
    }
}
