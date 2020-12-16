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
    func chatCleared(at index: Int)
    func chatRemoved(at index: Int)
    
    func chatCompanionUpdated(at index: Int, companion: UserInfo)
    func chatMessageUpdated(at index: Int, message: MessageInfo)
    func chatUnreadMessagesCountUpdated(at index: Int, count: Int)
}

final class ChatsInteractor {
    weak var presenter: IChatsInteractorOutput?
    
    private let coreDataChatsManager = CoreDataChatsManager()
    private let firebaseChatsManager = FirebaseDatabaseChatsManager()
    
    init() {
        observeNotifications()
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
        firebaseChatsManager.clearChat(userIdentifier: userIdentifier, chatIdentifier: chatIdentifier)
        
        presenter?.chatCleared(at: index)
    }
    
    func removeChat(at index: Int) {
        coreDataChatsManager.removeChat(at: index)
        // Later: clear messages
        
        presenter?.chatRemoved(at: index)
    }
}

// MARK: - Private Methods

private extension ChatsInteractor {
    func observeNotifications() {
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
        }
    }
}

// MARK: - Actions

private extension ChatsInteractor {
    @objc func userSignedOut() {
        coreDataChatsManager.clear()
    }
}
