import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            window.rootViewController = UIViewController()
        } else {
            let navigationController = UINavigationController()
            navigationController.viewControllers = [WeatherListFlow.make(navigationController: navigationController)]
            window.rootViewController = navigationController
        }
        window.makeKeyAndVisible()
        self.window = window
    }
}
