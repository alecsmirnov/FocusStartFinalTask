//
//  ChatsRouter.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

import UIKit

protocol IChatsRouter: AnyObject {
    func openMenuViewController()
    func openChatLogViewController(with user: UserInfo)
    func openChatLogViewController(with chat: ChatInfo)
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
    
    func openChatLogViewController(with user: UserInfo) {
        let chatLogViewController = ChatLogAssembly.createChatLogViewController(with: user)
        
        viewController?.navigationController?.pushViewController(chatLogViewController, animated: true)
    }
    
    func openChatLogViewController(with chat: ChatInfo) {
        let chatLogViewController = ChatLogAssembly.createChatLogViewController(with: chat)
        
        viewController?.navigationController?.pushViewController(chatLogViewController, animated: true)
    }
    
    func openSearchViewController(delegate: ISearchPresenterDelegate?) {
        let searchViewController = SearchAssembly.createSearchViewController(delegate: delegate)
        let navigationController = UINavigationController(rootViewController: searchViewController)
        
        navigationController.modalPresentationStyle = .fullScreen
        
        viewController?.present(navigationController, animated: true)
    }
}
