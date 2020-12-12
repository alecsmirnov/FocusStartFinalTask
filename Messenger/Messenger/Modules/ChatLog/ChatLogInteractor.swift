//
//  ChatLogInteractor.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

import Foundation

protocol IChatLogInteractor: AnyObject {
    func createChat(withUser userIdentifier: String) -> String?
    
    func sendMessage(_ messageType: ChatsMessagesType, toChat chatIdentifier: String)
    
    func observeMessages(for chatIdentifier: String)
}

protocol IChatLogInteractorOutput: AnyObject {
    func addedMessage(_ message: ChatsMessagesValue)
}

final class ChatLogInteractor {
    weak var presenter: IChatLogInteractorOutput?
}

// MARK: - IChatLogInteractor

extension ChatLogInteractor: IChatLogInteractor {
    func createChat(withUser userIdentifier: String) -> String? {
        guard let identifier = FirebaseAuthService.currentUser()?.uid else { return nil }
        
        return FirebaseDatabaseService.createChatBetween(userIdentifier1: identifier,
                                                         userIdentifier2: userIdentifier)
    }
    
    func sendMessage(_ messageType: ChatsMessagesType, toChat chatIdentifier: String) {
        guard let identifier = FirebaseAuthService.currentUser()?.uid else { return }
        
        let message = ChatsMessagesValue(senderIdentifier: identifier,
                                         messageType: messageType,
                                         timestamp: Date().timeIntervalSince1970,
                                         isRead: false)
        
        FirebaseDatabaseService.sendMessage(message, chatIdentifier: chatIdentifier)
    }
    
    func observeMessages(for chatIdentifier: String) {
//        FirebaseDatabaseService.observeMessages(for: chatIdentifier) { [weak self] message in
//            self?.presenter?.addedMessage(message)
//        }
    }
}
