// Copyright © 2022 Jamit Labs GmbH. All rights reserved.

import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    // NOTE: Multiple windows can be enabled in the info.plist
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window: UIWindow = .init(windowScene: windowScene)
    }
}
