//
//  ChatsRouter.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

import UIKit

protocol IChatsRouter: AnyObject {
    func extendMenu()
    
    func openChatLogViewController(with user: UserInfo)
    func openChatLogViewController(with chat: ChatInfo)
    func openSearchViewController(delegate: ISearchPresenterDelegate?)
    
    func openLaunchViewController()
}

final class ChatsRouter {
    // MARK: Properties
    
    private enum Constants {
        static let presentDuration = 0.4
        static let dismissDuration = 0.4
    }
    
    private weak var viewController: ChatsViewController?
    private weak var menuChatsViewController: MenuChatsViewController?
    
    // MARK: Transition Animations
    
    private let transitionDelegate: TransitionDelegate = {
        let presentAnimation = SlideAnimationController(duration: Constants.presentDuration, animationType: .present)
        let dismissAnimation = SlideAnimationController(duration: Constants.dismissDuration, animationType: .dismiss)
        
        let transitionDelegate = TransitionDelegate(
            presentAnimationController: presentAnimation,
            dismissAnimationController: dismissAnimation)
        
        return transitionDelegate
    }()
    
    // MARK: Initialization
    
    init(viewController: ChatsViewController, menuChatsViewController: MenuChatsViewController?) {
        self.viewController = viewController
        self.menuChatsViewController = menuChatsViewController
    }
}

// MARK: - IChatsRouter

extension ChatsRouter: IChatsRouter {
    func extendMenu() {
        menuChatsViewController?.extendMenu()
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
        
        // Animation bug when used with slide menu
        //navigationController.modalPresentationStyle = .custom
        //navigationController.transitioningDelegate = transitionDelegate
        
        viewController?.present(navigationController, animated: true)
    }
    
    func openLaunchViewController() {
        menuChatsViewController?.extendMenu { [weak self] in
            self?.menuChatsViewController?.navigationController?.popToRootViewController(animated: false)
        }
    }
}
