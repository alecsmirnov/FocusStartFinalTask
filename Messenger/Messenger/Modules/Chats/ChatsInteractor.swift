//
//  ChatsInteractor.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

import Foundation

protocol IChatsInteractor: AnyObject {
    func fetchChats()
    
    func clearChat(at index: Int)
    func removeChat(at index: Int)
}

protocol IChatsInteractorOutput: AnyObject {
    func fetchChatsSuccess(chats: [ChatInfo])
    
    func chatAdded(chat: ChatInfo)
    func chatRemoved(at index: Int)
    
    func chatCompanionUpdated(at index: Int, companion: UserInfo)
    func chatMessageUpdated(at index: Int, message: MessageInfo?)
    func chatUnreadMessagesCountUpdated(at index: Int, count: Int)
    func chatOnlineStatusUpdate(at index: Int, isOnline: Bool)
}

final class ChatsInteractor {
    weak var presenter: IChatsInteractorOutput?
    
    private let coreDataChatsManager = CoreDataChatsManager()
    private let firebaseChatsManager = FirebaseDatabaseChatsManager()
    
    init() {
        observeSignOutNotification()
    }
}

// MARK: - IChatsInteractor

extension ChatsInteractor: IChatsInteractor {
    func fetchChats() {
        guard let userIdentifier = FirebaseAuthService.currentUser()?.uid else { return }
        
        let latestUpdateTime = coreDataChatsManager.getLatestUpdateTimestamp()
        
        loadStoredChats()
        observeLoadedChats(userIdentifier: userIdentifier, latestUpdateTime: latestUpdateTime)
        observeAddedChats(userIdentifier: userIdentifier, latestUpdateTime: latestUpdateTime)
    }
    
    func clearChat(at index: Int) {
        guard let userIdentifier = FirebaseAuthService.currentUser()?.uid,
              let chatIdentifier = coreDataChatsManager.getChatIdentifier(by: index) else { return }
        
        coreDataChatsManager.updateChatLatestMessage(at: index, message: nil)
        firebaseChatsManager.clearChat(chatIdentifier: chatIdentifier, userIdentifier: userIdentifier)
    }
    
    func removeChat(at index: Int) {
        guard let userIdentifier = FirebaseAuthService.currentUser()?.uid,
              let chatIdentifier = coreDataChatsManager.getChatIdentifier(by: index) else { return }
        
        coreDataChatsManager.removeChat(at: index)
        firebaseChatsManager.removeChat(chatIdentifier: chatIdentifier, userIdentifier: userIdentifier)
        
        presenter?.chatRemoved(at: index)
    }
}

// MARK: - Private Methods

private extension ChatsInteractor {
    func loadStoredChats() {
        let storedChats = coreDataChatsManager.getChats()
        
        if !storedChats.isEmpty {
            presenter?.fetchChatsSuccess(chats: storedChats)
        }
    }
    
    func observeLoadedChats(userIdentifier: String, latestUpdateTime: TimeInterval) {
        let chats = coreDataChatsManager.getChats()
        
        firebaseChatsManager.observeLoadedChats(userIdentifier: userIdentifier,
                                                latestUpdateTime: latestUpdateTime,
                                                chats: chats) { [weak self] chat in
            self?.chatAdded(chat: chat)
        } chatRemovedCompletion: { [weak self] chatIdentifier in
            self?.chatRemoved(chatIdentifier: chatIdentifier)
        } pairChatUpdated: { [weak self] chatIdentifier, companion in
            self?.pairChatUpdated(chatIdentifier: chatIdentifier, companion: companion)
        } groupChatUpdated: { chatIdentifier, group in

        } chatLatestMessageUpdated: { [weak self] chatIdentifier, message in
            self?.chatLatestMessageUpdated(chatIdentifier: chatIdentifier, message: message)
        } chatUnreadMessagesUpdated: { [weak self] chatIdentifier, count in
            self?.chatUnreadMessagesUpdated(chatIdentifier: chatIdentifier, count: count)
        } chatOnlineStatusUpdate: { [weak self] chatIdentifier, isOnline in
            self?.chatOnlineStatusUpdated(chatIdentifier: chatIdentifier, isOnline: isOnline)
        }
    }
    
    func observeAddedChats(userIdentifier: String, latestUpdateTime: TimeInterval) {
        firebaseChatsManager.observeChats(userIdentifier: userIdentifier,
                                          latestUpdateTime: latestUpdateTime) { [weak self] chat in
            self?.chatAdded(chat: chat)
        } chatRemovedCompletion: { [weak self] chatIdentifier in
            self?.chatRemoved(chatIdentifier: chatIdentifier)
        } pairChatUpdated: { [weak self] chatIdentifier, companion in
            self?.pairChatUpdated(chatIdentifier: chatIdentifier, companion: companion)
        } groupChatUpdated: { chatIdentifier, group in

        } chatLatestMessageUpdated: { [weak self] chatIdentifier, message in
            self?.chatLatestMessageUpdated(chatIdentifier: chatIdentifier, message: message)
        } chatUnreadMessagesUpdated: { [weak self] chatIdentifier, count in
            self?.chatUnreadMessagesUpdated(chatIdentifier: chatIdentifier, count: count)
        } chatOnlineStatusUpdate: { [weak self] chatIdentifier, isOnline in
            self?.chatOnlineStatusUpdated(chatIdentifier: chatIdentifier, isOnline: isOnline)
        }
    }
    
    func chatAdded(chat: ChatInfo) {
        coreDataChatsManager.appendChat(chat: chat)
        presenter?.chatAdded(chat: chat)
    }
    
    func chatRemoved(chatIdentifier: String) {
        if let index = coreDataChatsManager.getChatIndex(by: chatIdentifier) {
            coreDataChatsManager.removeChat(at: chatIdentifier)
            presenter?.chatRemoved(at: index)
        }
    }
    
    func pairChatUpdated(chatIdentifier: String, companion: UserInfo) {
        if let index = coreDataChatsManager.getChatIndex(by: chatIdentifier) {
            coreDataChatsManager.updateChatCompanion(at: chatIdentifier, companion: companion)
            presenter?.chatCompanionUpdated(at: index, companion: companion)
        }
    }
    
    func chatLatestMessageUpdated(chatIdentifier: String, message: MessageInfo?) {
        if let index = coreDataChatsManager.getChatIndex(by: chatIdentifier) {
            coreDataChatsManager.updateChatLatestMessage(at: chatIdentifier, message: message)
            presenter?.chatMessageUpdated(at: index, message: message)
        }
    }
    
    func chatUnreadMessagesUpdated(chatIdentifier: String, count: Int) {
        if let index = coreDataChatsManager.getChatIndex(by: chatIdentifier) {
            coreDataChatsManager.updateChatUnreadMessagesCount(at: chatIdentifier, count: count)
            presenter?.chatUnreadMessagesCountUpdated(at: index, count: count)
        }
    }
    
    func chatOnlineStatusUpdated(chatIdentifier: String, isOnline: Bool) {
        if let index = coreDataChatsManager.getChatIndex(by: chatIdentifier) {
            presenter?.chatOnlineStatusUpdate(at: index, isOnline: isOnline)
        }
    }
    
    func observeSignOutNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(userSignedOut), name: .SignOut, object: nil)
    }
}

// MARK: - Actions

private extension ChatsInteractor {
    @objc func userSignedOut() {
        coreDataChatsManager.clear()
    }
}
