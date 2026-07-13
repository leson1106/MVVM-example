import MVVMDomain
import MVVMNetwork
import RxSwift
import UIKit

enum WeatherListFlow {
    static func make(navigationController: UINavigationController?) -> UIViewController {
        let navigator = WeatherListNavigatorImpl(navigationController: navigationController)
        let bookmarkStore = WeatherDependencies.makeBookmarkStore()
        let useCase = WeatherListUseCaseImpl(
            repository: WeatherDependencies.makeRepository(),
            bookmarkStore: bookmarkStore
        )
        let viewModel = WeatherListViewModel(useCase: useCase, navigator: navigator)
        return WeatherListViewController(viewModel: viewModel)
    }
}
