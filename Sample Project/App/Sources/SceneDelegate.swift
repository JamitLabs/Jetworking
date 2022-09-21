// Copyright © 2022 Jamit Labs GmbH. All rights reserved.

import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIStoryboard(name: "MainViewController", bundle: nil).instantiateInitialViewController()
        self.window = window
        window.makeKeyAndVisible()
    }
}
