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
        
        print("update time: \(latestUpdateTime)")
        print("chats count: \(coreDataChatsManager.getChats().count)")
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
    func observeSignOutNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(userSignedOut), name: .SignOut, object: nil)
    }
    
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
            self?.coreDataChatsManager.appendChat(chat: chat)
            self?.presenter?.chatAdded(chat: chat)
        } chatRemovedCompletion: { [weak self] chatIdentifier in
            if let index = self?.coreDataChatsManager.getChatIndex(by: chatIdentifier) {
                self?.coreDataChatsManager.removeChat(at: chatIdentifier)
                self?.presenter?.chatRemoved(at: index)
            }
        } pairChatUpdated: { [weak self] chatIdentifier, companion in
            if let index = self?.coreDataChatsManager.getChatIndex(by: chatIdentifier) {
                self?.coreDataChatsManager.updateChatCompanion(at: chatIdentifier, companion: companion)
                self?.presenter?.chatCompanionUpdated(at: index, companion: companion)
            }
        } groupChatUpdated: { chatIdentifier, group in

        } chatLatestMessageUpdated: { [weak self] chatIdentifier, message in
            if let index = self?.coreDataChatsManager.getChatIndex(by: chatIdentifier) {
                self?.coreDataChatsManager.updateChatLatestMessage(at: chatIdentifier, message: message)
                self?.presenter?.chatMessageUpdated(at: index, message: message)
            }
        } chatUnreadMessagesUpdated: { [weak self] chatIdentifier, count in
            if let index = self?.coreDataChatsManager.getChatIndex(by: chatIdentifier) {
                self?.coreDataChatsManager.updateChatUnreadMessagesCount(at: chatIdentifier, count: count)
                self?.presenter?.chatUnreadMessagesCountUpdated(at: index, count: count)
            }
        } chatOnlineStatusUpdate: { [weak self] chatIdentifier, isOnline in
            if let index = self?.coreDataChatsManager.getChatIndex(by: chatIdentifier) {
                self?.presenter?.chatOnlineStatusUpdate(at: index, isOnline: isOnline)
            }
        }
    }
    
    func observeAddedChats(userIdentifier: String, latestUpdateTime: TimeInterval) {
        firebaseChatsManager.observeChats(userIdentifier: userIdentifier,
                                          latestUpdateTime: latestUpdateTime) { [weak self] chat in
            self?.coreDataChatsManager.appendChat(chat: chat)
            self?.presenter?.chatAdded(chat: chat)
        } chatRemovedCompletion: { [weak self] chatIdentifier in
            if let index = self?.coreDataChatsManager.getChatIndex(by: chatIdentifier) {
                self?.coreDataChatsManager.removeChat(at: chatIdentifier)
                self?.presenter?.chatRemoved(at: index)
            }
        } pairChatUpdated: { [weak self] chatIdentifier, companion in
            if let index = self?.coreDataChatsManager.getChatIndex(by: chatIdentifier) {
                self?.coreDataChatsManager.updateChatCompanion(at: chatIdentifier, companion: companion)
                self?.presenter?.chatCompanionUpdated(at: index, companion: companion)
            }
        } groupChatUpdated: { chatIdentifier, group in

        } chatLatestMessageUpdated: { [weak self] chatIdentifier, message in
            if let index = self?.coreDataChatsManager.getChatIndex(by: chatIdentifier) {
                self?.coreDataChatsManager.updateChatLatestMessage(at: chatIdentifier, message: message)
                self?.presenter?.chatMessageUpdated(at: index, message: message)
            }
        } chatUnreadMessagesUpdated: { [weak self] chatIdentifier, count in
            if let index = self?.coreDataChatsManager.getChatIndex(by: chatIdentifier) {
                self?.coreDataChatsManager.updateChatUnreadMessagesCount(at: chatIdentifier, count: count)
                self?.presenter?.chatUnreadMessagesCountUpdated(at: index, count: count)
            }
        } chatOnlineStatusUpdate: { [weak self] chatIdentifier, isOnline in
            if let index = self?.coreDataChatsManager.getChatIndex(by: chatIdentifier) {
                self?.presenter?.chatOnlineStatusUpdate(at: index, isOnline: isOnline)
            }
        }
    }
}

// MARK: - Actions

private extension ChatsInteractor {
    @objc func userSignedOut() {
        coreDataChatsManager.clear()
    }
}
