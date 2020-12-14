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
    func readMessage(_ message: Message, chatIdentifier: String)
    
    func fetchMessages(chatIdentifier: String)
    func observeMessages(chatIdentifier: String)
}

protocol IChatLogInteractorOutput: AnyObject {
    func addedMessage(_ message: Message)
    func updateMessage(_ message: Message)
}

final class ChatLogInteractor {
    weak var presenter: IChatLogInteractorOutput?
}

// MARK: - IChatLogInteractor

extension ChatLogInteractor: IChatLogInteractor {
    func createChat(withUser userIdentifier: String) -> String? {
        guard let identifier = FirebaseAuthService.currentUser()?.uid,
              let chatIdentifier = FirebaseDatabaseService.createChatBetween(userIdentifier1: identifier,
                                                                             userIdentifier2: userIdentifier) else {
            return nil
        }
        
        observeMessages(chatIdentifier: chatIdentifier)
        
        return chatIdentifier
    }
    
    func sendMessage(_ messageType: ChatsMessagesType, toChat chatIdentifier: String) {
        guard let identifier = FirebaseAuthService.currentUser()?.uid else { return }
        
        let message = ChatsMessagesValue(senderIdentifier: identifier,
                                         messageType: messageType,
                                         timestamp: Date().timeIntervalSince1970,
                                         isRead: false)
        
        FirebaseDatabaseService.sendMessage(message, chatIdentifier: chatIdentifier)
    }
    
    func readMessage(_ message: Message, chatIdentifier: String) {        
        guard let userIdentifier = FirebaseAuthService.currentUser()?.uid else { return }
        
        if message.data.senderIdentifier != userIdentifier && !message.data.isRead {
            FirebaseDatabaseService.markMessageAsRead(chatIdentifier: chatIdentifier,
                                                      userIdentifier: userIdentifier,
                                                      messageIdentifier: message.identifier)
        }
    }
    
    func fetchMessages(chatIdentifier: String) {
        
    }
    
    func observeMessages(chatIdentifier: String) {
        guard let userIdentifier = FirebaseAuthService.currentUser()?.uid else { return }
        
        FirebaseDatabaseService.observeChatMessages(userIdentifier: userIdentifier,
                                                    chatIdentifier: chatIdentifier) { [weak self] message in
            self?.presenter?.addedMessage(message)
            
            FirebaseDatabaseService.observeChatMessagesChange(chatIdentifier: chatIdentifier) { message in
                self?.presenter?.updateMessage(message)
            }
        }
    }
}
