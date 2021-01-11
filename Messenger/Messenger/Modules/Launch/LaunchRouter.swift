//
//  LaunchRouter.swift
//  Messenger
//
//  Created by Admin on 06.12.2020.
//

import UIKit

protocol ILaunchRouter: AnyObject {
    func openLoginViewController()
    func openMenuChatsViewController()
}

final class LaunchRouter {
    // MARK: Properties
    
    private weak var viewController: LaunchViewController?
    
    // MARK: Initialization
    
    init(viewController: LaunchViewController) {
        self.viewController = viewController
    }
}

// MARK: - ILaunchRouter

extension LaunchRouter: ILaunchRouter {
    func openLoginViewController() {
        let loginViewController = LoginAssembly.createLoginViewController()
        
        viewController?.navigationController?.setNavigationBarHidden(true, animated: false)
        viewController?.navigationController?.pushViewController(loginViewController, animated: false)
    }
    
    func openMenuChatsViewController() {
        let menuChatsViewController = MenuChatsAssembly.createMenuChatsViewController()
        
        viewController?.navigationController?.setNavigationBarHidden(true, animated: false)
        viewController?.navigationController?.pushViewController(menuChatsViewController, animated: false)
    }
}
