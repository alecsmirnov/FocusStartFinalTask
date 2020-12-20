//
//  MenuRouter.swift
//  Messenger
//
//  Created by Admin on 07.12.2020.
//

protocol IMenuRouter: AnyObject {
    func extendMenu()
    
    func openLaunchViewController()
    func openProfileViewController(with user: UserInfo?)
}

final class MenuRouter {
    // MARK: Properties
    
    private weak var viewController: MenuViewController?
    private weak var menuChatsViewController: MenuChatsViewController?
    
    // MARK: Initialization
    
    init(viewController: MenuViewController, menuChatsViewController: MenuChatsViewController?) {
        self.viewController = viewController
        self.menuChatsViewController = menuChatsViewController
    }
}

// MARK: - IMenuRouter

extension MenuRouter: IMenuRouter {
    func extendMenu() {
        menuChatsViewController?.extendMenu()
    }
    
    func openLaunchViewController() {
        menuChatsViewController?.extendMenu { [weak self] in
            self?.menuChatsViewController?.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func openProfileViewController(with user: UserInfo?) {
        menuChatsViewController?.extendMenu { [weak self] in
            let profileViewController = ProfileAssembly.createProfileViewController(with: user)
        
            profileViewController.modalPresentationStyle = .fullScreen
        
            self?.viewController?.present(profileViewController, animated: true)
        }
    }
}
