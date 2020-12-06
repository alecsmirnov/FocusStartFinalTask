//
//  LaunchAssembly.swift
//  Messenger
//
//  Created by Admin on 06.12.2020.
//

import UIKit

enum LaunchAssembly {
    static func createLaunchNavigationViewController() -> UINavigationController {
        let viewController = LaunchViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        
        let interactor = LaunchInteractor()
        let presenter = LaunchPresenter()
        let router = LaunchRouter(viewController: viewController)
        
        viewController.presenter = presenter
        
        presenter.viewController = viewController
        presenter.interactor = interactor
        presenter.router = router
        
        return navigationController
    }
}
