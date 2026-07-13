import MVVMDomain
import MVVMNetwork
import RxSwift
import UIKit

enum WeatherDetailFlow {
    static func make(navigationController: UINavigationController?, date: String) -> UIViewController {
        let navigator = WeatherDetailNavigatorImpl()
        let bookmarkStore = WeatherDependencies.makeBookmarkStore()
        let useCase = WeatherDetailUseCaseImpl(
            repository: WeatherDependencies.makeRepository(),
            bookmarkStore: bookmarkStore
        )
        let viewModel = WeatherDetailViewModel(date: date, useCase: useCase, navigator: navigator)
        let viewController = WeatherDetailViewController(viewModel: viewModel)
        navigator.attach(viewController: viewController)
        return viewController
    }
}
