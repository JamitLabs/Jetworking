// Copyright © 2022 Jamit Labs GmbH. All rights reserved.

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    // MARK: - Methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        if #available(iOS 13.0, *) {
            // NOTE: If iOS 13 is available SceneDelegate will be used to initialize the view
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = UIStoryboard(name: "MainViewController", bundle: nil).instantiateInitialViewController()
            window?.makeKeyAndVisible()
        }
        
        return true
    }
}
