//
//  MenuChatsAssembly.swift
//  Messenger
//
//  Created by Admin on 20.12.2020.
//

import UIKit

enum MenuChatsAssembly {
    static func createMenuChatsViewController() -> MenuChatsViewController {
        let menuChatsViewController = MenuChatsViewController()
        
        let chatsViewController = ChatsAssembly.createChatsViewController(
            menuChatsViewController: menuChatsViewController)
        let menuViewController = MenuAssembly.createMenuViewController(menuChatsViewController: menuChatsViewController)
        let chatsNavigationController = UINavigationController(rootViewController: chatsViewController)
        
        menuChatsViewController.chatsNavigationController = chatsNavigationController
        menuChatsViewController.menuViewController = menuViewController
        
        return menuChatsViewController
    }
}
