//
//  SceneDelegate.swift
//  Messenger
//
//  Created by Admin on 21.11.2020.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = LaunchAssembly.createLaunchNavigationController()
        window?.makeKeyAndVisible()
    }
}
