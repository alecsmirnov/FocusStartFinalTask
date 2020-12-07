//
//  ChatRouter.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

protocol IChatRouter: AnyObject {}

final class ChatRouter {
    // MARK: Properties
    
    private weak var viewController: ChatViewController?
    
    init(viewController: ChatViewController) {
        self.viewController = viewController
    }
}

// MARK: - IChatRouter

extension ChatRouter: IChatRouter {}
