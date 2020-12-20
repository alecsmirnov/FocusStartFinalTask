//
//  ChatLogInteractor.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

import Foundation

protocol IChatLogInteractor: AnyObject {
    func fetchMessages()
    func fetchPreviousMessages()
    func fetchChatTitleInfo()
    
    func sendMessage(_ messageType: ChatsMessagesType)
    func readMessage(_ message: MessageInfo)
}

protocol IChatLogInteractorOutput: AnyObject {
    func addedMessage(_ message: MessageInfo)
    func updateMessage(_ message: MessageInfo)
    
    func fetchMessagesSuccess(_ messages: [MessageInfo])
    func fetchPreviousMessagesSuccess(_ previousMessages: [MessageInfo])
    func fetchPreviousMessagesFail()
    
    func fetchChatTitleInfoSuccess(title: String)
}

final class ChatLogInteractor {
    weak var presenter: IChatLogInteractorOutput?
    
    private enum Constants {
        static let storedMessagesCount = 3
    }
    
    private var chat: ChatInfo?
    private var topMessageTimestamp: TimeInterval?
    
    private let coreDataChatLogManager = CoreDataChatLogManager(maxSize: Constants.storedMessagesCount)
}

// MARK: - Public Methods

extension ChatLogInteractor {
    func initPairChat(with companion: UserInfo) {
        if let chat = registerPairChat(with: companion) {
            initGroupChat(chat: chat)
        }
    }
    
    func initGroupChat(chat: ChatInfo) {
        coreDataChatLogManager.fetchData(chatIdentifier: chat.identifier)
        
        self.chat = chat
    }
}

// MARK: - IChatLogInteractor

extension ChatLogInteractor: IChatLogInteractor {
    func fetchMessages() {
        loadStoredMessages()
        observeMessages()
        
        // Test
        
        if let chatIdentifier = chat?.identifier {
            //FirebaseMessageService.observeUpdatedMessages(chatIdentifier: chatIdentifier)
        }
    }
    
    func fetchPreviousMessages() {
        guard let userIdentifier = FirebaseAuthService.currentUser()?.uid,
              let chatIdentifier = chat?.identifier,
              let topMessageTimestamp = topMessageTimestamp else {
            presenter?.fetchPreviousMessagesFail()
            
            return
        }
        
        let messagesLimit = Constants.storedMessagesCount
        
        FirebaseMessageService.fetchPreviousMessages(chatIdentifier: chatIdentifier,
                                                     userIdentifier: userIdentifier,
                                                     endingAt: topMessageTimestamp,
                                                     limit: messagesLimit) { [weak self] previousMessages in
            if let previousMessages = previousMessages {
                self?.topMessageTimestamp = previousMessages.first?.timestamp
                self?.presenter?.fetchPreviousMessagesSuccess(previousMessages)
            } else {
                self?.presenter?.fetchPreviousMessagesFail()
            }
        }
    }
    
    func fetchChatTitleInfo() {
        guard let chat = chat else { return }
        
        let title = "\(chat.companion.firstName) \(chat.companion.lastName ?? "")"
        
        presenter?.fetchChatTitleInfoSuccess(title: title)
    }
    
    func sendMessage(_ messageType: ChatsMessagesType) {
        guard let userIdentifier = FirebaseAuthService.currentUser()?.uid,
              let chat = chat else { return }
        
        FirebaseChatsService.isChatExist(chatIdentifier: chat.identifier,
                                           userIdentifier: userIdentifier) { isExist in
            if !isExist {
                FirebaseChatsService.createPairChat(chatIdentifier: chat.identifier,
                                                            userIdentifier1: userIdentifier,
                                                            userIdentifier2: chat.companion.identifier)
            }
        }
        
        FirebaseMessageService.sendMessage(messageType,
                                           chatIdentifier: chat.identifier,
                                           senderIdentifier: userIdentifier)
    }
    
    func readMessage(_ message: MessageInfo) {
        guard let userIdentifier = FirebaseAuthService.currentUser()?.uid,
              let chatIdentifier = chat?.identifier else { return }

        if message.isIncoming ?? false {
            FirebaseMessageService.readMessage(chatIdentifier: chatIdentifier,
                                               userIdentifier: userIdentifier,
                                               messageIdentifier: message.identifier)
        }
    }
}

// MARK: - Private Methods

private extension ChatLogInteractor {
    func loadStoredMessages() {
        let messages = coreDataChatLogManager.getMessages()
        
        if !messages.isEmpty {
            topMessageTimestamp = messages.first?.timestamp
            presenter?.fetchMessagesSuccess(messages)
        }
    }
    
    func observeMessages() {
        guard let userIdentifier = FirebaseAuthService.currentUser()?.uid,
              let chatIdentifier = chat?.identifier else { return }
        
        let latestUpdateTime = coreDataChatLogManager.getLatestUpdateTimestamp()
        
        let messagesLimit = Constants.storedMessagesCount + (chat?.unreadMessagesCount ?? 0)
        
        FirebaseMessageService.observeAddedMessages(chatIdentifier: chatIdentifier,
                                                    userIdentifier: userIdentifier,
                                                    latestUpdateTime: latestUpdateTime,
                                                    limit: messagesLimit) { [weak self] message in
            self?.coreDataChatLogManager.appendMessage(message)
            self?.presenter?.addedMessage(message)
        }
    }
    
    func registerPairChat(with companion: UserInfo) -> ChatInfo? {
        guard let userIdentifier = FirebaseAuthService.currentUser()?.uid else { return nil }
        
        let chatIdentifier = FirebaseChatsService.getPairChatIdentifier(userIdentifier1: userIdentifier,
                                                                        userIdentifier2: companion.identifier)
        
        return ChatInfo(identifier: chatIdentifier, companion: companion)
    }
}
