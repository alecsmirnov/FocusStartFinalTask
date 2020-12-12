//
//  ChatsRouter.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

import UIKit

protocol IChatsRouter: AnyObject {
    func openMenuViewController()
    func openChatLogViewController(with user: UserInfo, chatIdentifier: String?)
    func openSearchViewController(delegate: ISearchPresenterDelegate?)
}

final class ChatsRouter {
    // MARK: Properties
    
    private weak var viewController: ChatsViewController?
    
    // MARK: Initialization
    
    init(viewController: ChatsViewController) {
        self.viewController = viewController
    }
}

// MARK: - IChatsRouter

extension ChatsRouter: IChatsRouter {
    func openMenuViewController() {
        let menuViewController = MenuAssembly.createMenuViewController()
        
        viewController?.navigationController?.pushViewController(menuViewController, animated: true)
    }
    
    func openChatLogViewController(with user: UserInfo, chatIdentifier: String?) {
        let chatLogViewController = ChatLogAssembly.createChatLogViewController(with: user, chatIdentifier: chatIdentifier)
        
        viewController?.navigationController?.pushViewController(chatLogViewController, animated: true)
    }
    
    func openSearchViewController(delegate: ISearchPresenterDelegate?) {
        let searchViewController = SearchAssembly.createSearchViewController(delegate: delegate)
        let navigationController = UINavigationController(rootViewController: searchViewController)
        
        navigationController.modalPresentationStyle = .fullScreen
        
        viewController?.present(navigationController, animated: true)
    }
}
