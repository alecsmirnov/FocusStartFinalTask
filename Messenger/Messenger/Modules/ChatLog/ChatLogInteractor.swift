//
//  ChatLogInteractor.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

import Foundation

protocol IChatLogInteractor: AnyObject {
    func sendMessage(_ messageType: ChatsMessagesType, to chat: ChatInfo)
    func readMessage(_ message: MessageInfo, chatIdentifier: String)
    
    func fetchMessages(chatIdentifier: String)
    func observeMessages(chatIdentifier: String)
    
    func loadLastMessages(chatIdentifier: String, topMessageIdentifier: String)
    
    func registerPairChat(with companion: UserInfo?) -> ChatInfo?
}

protocol IChatLogInteractorOutput: AnyObject {
    func addedMessage(_ message: MessageInfo)
    func updateMessage(_ message: MessageInfo)
    
    // Test
    
    func addedPreviousMessage(_ message: MessageInfo)
}

final class ChatLogInteractor {
    weak var presenter: IChatLogInteractorOutput?
    
    private let firebaseChatLogManager = FirebaseDatabaseChatLogManager()
}

// MARK: - IChatLogInteractor

extension ChatLogInteractor: IChatLogInteractor {    
    func sendMessage(_ messageType: ChatsMessagesType, to chat: ChatInfo) {
        guard let userIdentifier = FirebaseAuthService.currentUser()?.uid else { return }
        
        if !chat.isGroup {
            if let companion = chat.companion {
                firebaseChatLogManager.isChatExist(chatIdentifier: chat.identifier,
                                                   userIdentifier: userIdentifier) { [weak self] isExist in
                    if !isExist {
                        self?.firebaseChatLogManager.createPairChat(chatIdentifier: chat.identifier,
                                                                    userIdentifier1: userIdentifier,
                                                                    userIdentifier2: companion.identifier)
                    }
                }
            }
        }
        
        firebaseChatLogManager.sendMessage(messageType,
                                           chatIdentifier: chat.identifier,
                                           senderIdentifier: userIdentifier)
    }
    
    func readMessage(_ message: MessageInfo, chatIdentifier: String) {        
//        guard let userIdentifier = FirebaseAuthService.currentUser()?.uid else { return }
//
//        if message.data.senderIdentifier != userIdentifier && !message.data.isRead {
//            FirebaseDatabaseService.markMessageAsRead(chatIdentifier: chatIdentifier,
//                                                      userIdentifier: userIdentifier,
//                                                      messageIdentifier: message.identifier)
//        }
    }
    
    func fetchMessages(chatIdentifier: String) {
        
    }
    
    func loadLastMessages(chatIdentifier: String, topMessageIdentifier: String) {
        guard let userIdentifier = FirebaseAuthService.currentUser()?.uid else { return }
        
        firebaseChatLogManager.observeChatLogAddedMessagesWithLastNumber(chatIdentifier: chatIdentifier,
                                                                         userIdentifier: userIdentifier,
                                                                         latestUpdateTime: 1608019885.450429,
                                                                         toLast: 3,
                                                                         topMessageIdentifier: topMessageIdentifier
        ) { [weak self] message in
                self?.presenter?.addedPreviousMessage(message)
        }
    }
    
    func observeMessages(chatIdentifier: String) {
        guard let userIdentifier = FirebaseAuthService.currentUser()?.uid else { return }
        
        firebaseChatLogManager.observeChatLogAddedMessages(chatIdentifier: chatIdentifier,
                                                           userIdentifier: userIdentifier,
                                                           latestUpdateTime: 1608019885.450429) { [weak self] message in
            self?.presenter?.addedMessage(message)
            
//            FirebaseDatabaseService.observeChatMessagesChange(chatIdentifier: chatIdentifier) { message in
//                self?.presenter?.updateMessage(message)
//            }
        }
    }
    
    func registerPairChat(with companion: UserInfo?) -> ChatInfo? {
        guard let userIdentifier = FirebaseAuthService.currentUser()?.uid,
              let companion = companion else { return nil }
        
        let chatIdentifier = FirebaseDatabaseChatLogManager.getPairChatIdentifier(userIdentifier1: userIdentifier,
                                                                                  userIdentifier2: companion.identifier)
        
        return ChatInfo(identifier: chatIdentifier, isGroup: false, companion: companion)
    }
}
