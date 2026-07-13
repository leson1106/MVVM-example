import MVVMDomain
import MVVMNetwork
import XCTest
@testable import MVVM

final class WeatherListNavigatorTests: XCTestCase {
    func test_showDetail_pushesDetailViewController() {
        // given
        let navigationController = UINavigationController(rootViewController: UIViewController())
        let navigator = WeatherListNavigatorImpl(navigationController: navigationController)

        // when
        navigator.showDetail(date: "2024-03-18")

        // then
        XCTAssertEqual(navigationController.viewControllers.count, 2)
        XCTAssertTrue(navigationController.viewControllers.last is WeatherDetailViewController)
    }
}
