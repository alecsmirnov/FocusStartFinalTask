//
//  LaunchRouter.swift
//  Messenger
//
//  Created by Admin on 06.12.2020.
//

protocol ILaunchRouter: AnyObject {
    func openLoginViewController()
    func openChatsViewController()
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
        
        let navigationController = viewController?.navigationController
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        navigationController?.pushViewController(loginViewController, animated: false)
    }
    
    func openChatsViewController() {
        let chatsViewController = ChatsAssembly.createChatsViewController()
        
        let navigationController = viewController?.navigationController
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        navigationController?.pushViewController(chatsViewController, animated: false)
    }
}
