import MVVMDomain
import RxCocoa
import RxSwift
import UIKit

protocol WeatherListNavigator {
    func showDetail(date: String)
}

final class WeatherListNavigatorImpl: WeatherListNavigator {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    func showDetail(date: String) {
        let detailViewController = WeatherDetailFlow.make(
            navigationController: navigationController,
            date: date
        )
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
