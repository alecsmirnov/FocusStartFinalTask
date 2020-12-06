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
        
        loginViewController.modalPresentationStyle = .fullScreen
        
        viewController?.navigationController?.pushViewController(loginViewController, animated: false)
    }
    
    func openChatsViewController() {
        let chatsViewController = ChatsAssembly.createChatsViewController()
        
        chatsViewController.modalPresentationStyle = .fullScreen
        
        viewController?.navigationController?.pushViewController(chatsViewController, animated: false)
    }
}
