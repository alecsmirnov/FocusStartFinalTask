//
//  ChatsRouter.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

protocol IChatsRouter: AnyObject {
    func openMenuViewController()
    func openChatLogViewController(with user: UserData)
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
    
    func openChatLogViewController(with user: UserData) {
        let chatLogViewController = ChatLogAssembly.createChatLogViewController(with: user)
        
        viewController?.navigationController?.pushViewController(chatLogViewController, animated: true)
    }
    
    func openSearchViewController(delegate: ISearchPresenterDelegate?) {
        let searchViewController = SearchAssembly.createSearchViewController(delegate: delegate)
        
        viewController?.present(searchViewController, animated: true)
    }
}
