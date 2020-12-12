//
//  ChatLogRouter.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

protocol IChatLogRouter: AnyObject {}

final class ChatLogRouter {
    // MARK: Properties
    
    private weak var viewController: ChatLogViewController?
    
    init(viewController: ChatLogViewController) {
        self.viewController = viewController
    }
}

// MARK: - IChatLogRouter

extension ChatLogRouter: IChatLogRouter {}
