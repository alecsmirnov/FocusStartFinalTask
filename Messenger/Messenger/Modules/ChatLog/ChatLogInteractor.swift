//
//  ChatLogInteractor.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

import Foundation

protocol IChatLogInteractor: AnyObject {
    var chatInfo: ChatInfo? { get }
    
    func fetchMessages()
    func fetchPreviousMessages()
    
    func observeMessages()
    func stopObservingMessages()
    
    func sendMessage(_ messageType: ChatsMessagesType)
    func readMessage(_ message: MessageInfo)
}

protocol IChatLogInteractorOutput: AnyObject {
    func addedMessage(_ message: MessageInfo)
    func updateMessage(_ message: MessageInfo)
    
    func fetchMessagesSuccess(_ messages: [MessageInfo])
    func fetchPreviousMessagesSuccess(_ previousMessages: [MessageInfo])
    func fetchPreviousMessagesFail()
}

final class ChatLogInteractor {
    // MARK: Properties
    
    weak var presenter: IChatLogInteractorOutput?
    
    private enum Constants {
        static let previousMessagesLoadCount = 3    // For demonstration
        static let storedMessagesCount = 3          // For demonstration
    }
    
    private var chat: ChatInfo?
    private var topMessageTimestamp: TimeInterval?
    
    private let coreDataChatLogManager = CoreDataChatLogManager(maxSize: Constants.storedMessagesCount)
    private let firebaseChatLogManager = FirebaseChatLogManager()
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
    var chatInfo: ChatInfo? {
        return chat
    }
    
    func fetchMessages() {
        loadStoredMessages()
    }
    
    func fetchPreviousMessages() {
        guard
            let userIdentifier = FirebaseAuthService.currentUser()?.uid,
            let chatIdentifier = chat?.identifier,
            let topMessageTimestamp = topMessageTimestamp
        else {
            presenter?.fetchPreviousMessagesFail()
            
            return
        }
        
        let messagesLimit = Constants.previousMessagesLoadCount
        
        FirebaseMessageService.fetchPreviousMessages(
            chatIdentifier: chatIdentifier,
            userIdentifier: userIdentifier,
            endingAt: topMessageTimestamp,
            limit: messagesLimit) { [weak self] previousMessages in
            if let previousMessages = previousMessages {
                let definedPreviousMessages = previousMessages.map { ChatLogInteractor.defineIncomingMessage($0) }
                
                self?.topMessageTimestamp = previousMessages.first?.timestamp
                self?.presenter?.fetchPreviousMessagesSuccess(definedPreviousMessages)
            } else {
                self?.presenter?.fetchPreviousMessagesFail()
            }
        }
    }
    
    func observeMessages() {
        guard
            let userIdentifier = FirebaseAuthService.currentUser()?.uid,
            let chatIdentifier = chat?.identifier
        else {
            return
        }
        
        let latestUpdateTime = coreDataChatLogManager.getLatestUpdateTimestamp()
        
        let messagesLimit = Constants.storedMessagesCount + (chat?.unreadMessagesCount ?? 0)
        
        firebaseChatLogManager.observeAddedMessages(
            chatIdentifier: chatIdentifier,
            userIdentifier: userIdentifier,
            latestUpdateTime: latestUpdateTime,
            limit: messagesLimit) { [weak self] message in
            let definedMessage = ChatLogInteractor.defineIncomingMessage(message)
            
            self?.coreDataChatLogManager.appendMessage(message)
            self?.presenter?.addedMessage(definedMessage)
        }
    }
    
    func stopObservingMessages() {
        firebaseChatLogManager.removeAddedMessages()
    }
    
    func sendMessage(_ messageType: ChatsMessagesType) {
        guard
            let userIdentifier = FirebaseAuthService.currentUser()?.uid,
            let chat = chat
        else {
            return
        }
        
        FirebaseChatsService.isChatExist(chatIdentifier: chat.identifier, userIdentifier: userIdentifier) { isExist in
            if !isExist {
                FirebaseChatsService.createPairChat(
                    chatIdentifier: chat.identifier,
                    userIdentifier1: userIdentifier,
                    userIdentifier2: chat.companion.identifier)
            }
        }
        
        FirebaseMessageService.sendMessage(
            messageType,
            chatIdentifier: chat.identifier,
            senderIdentifier: userIdentifier)
    }
    
    func readMessage(_ message: MessageInfo) {
        guard
            let userIdentifier = FirebaseAuthService.currentUser()?.uid,
            let chatIdentifier = chat?.identifier
        else {
            return
        }

        if message.isIncoming ?? false {
            FirebaseMessageService.readMessage(
                chatIdentifier: chatIdentifier,
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
            let definedLoadedMessages = messages.map { ChatLogInteractor.defineIncomingMessage($0) }
            
            topMessageTimestamp = messages.first?.timestamp
            presenter?.fetchMessagesSuccess(definedLoadedMessages)
        }
    }
    
    func registerPairChat(with companion: UserInfo) -> ChatInfo? {
        guard let userIdentifier = FirebaseAuthService.currentUser()?.uid else { return nil }
        
        let chatIdentifier = FirebaseChatsService.getPairChatIdentifier(
            userIdentifier1: userIdentifier,
            userIdentifier2: companion.identifier)
        
        return ChatInfo(identifier: chatIdentifier, companion: companion)
    }
}

// MARK: - Helper Methods

private extension ChatLogInteractor {
    static func defineIncomingMessage(_ message: MessageInfo) -> MessageInfo {
        guard let userIdentifier = FirebaseAuthService.currentUser()?.uid else { return message }
        
        return FirebaseMessageService.determineMessageDirection(message, currentUserIdentifier: userIdentifier)
    }
}
