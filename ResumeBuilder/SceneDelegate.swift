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
        let listVC = ResumeListViewController()
        let nav = UINavigationController(rootViewController: listVC)
        nav.navigationBar.prefersLargeTitles = true
        window.rootViewController = nav
        window.makeKeyAndVisible()
        self.window = window
    }
}
