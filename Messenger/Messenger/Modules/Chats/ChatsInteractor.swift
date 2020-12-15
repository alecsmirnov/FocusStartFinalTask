//
//  ChatsInteractor.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

import Foundation

protocol IChatsInteractor: AnyObject {
    func fetchChats()
}

protocol IChatsInteractorOutput: AnyObject {
    func fetchChatsSuccess(chats: [ChatInfo])
    
    func chatAdded(chat: ChatInfo)
    func chatRemoved(chatIdentifier: String)
    
    func chatCompanionUpdated(chatIdentifier: String, companion: UserInfo)
    func chatMessageUpdated(chatIdentifier: String, message: MessageInfo)
    func chatUnreadMessagesCountUpdated(chatIdentifier: String, count: Int)
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
                self?.coreDataChatsManager.removeChat(at: index)
                self?.presenter?.chatRemoved(chatIdentifier: chatIdentifier)
            }
        } pairChatUpdated: { [weak self] chatIdentifier, companion in
            if let index = self?.coreDataChatsManager.getChatIndex(by: chatIdentifier) {
                self?.coreDataChatsManager.updateChatCompanion(at: index, companion: companion)
                self?.presenter?.chatCompanionUpdated(chatIdentifier: chatIdentifier, companion: companion)
            }
        } groupChatUpdated: { chatIdentifier, group in

        } chatLatestMessageUpdated: { [weak self] chatIdentifier, message in
            if let index = self?.coreDataChatsManager.getChatIndex(by: chatIdentifier) {
                self?.coreDataChatsManager.updateChatLatestMessage(at: index, message: message)
                self?.presenter?.chatMessageUpdated(chatIdentifier: chatIdentifier, message: message)
            }
        } chatUnreadMessagesUpdated: { [weak self] chatIdentifier, count in
            if let index = self?.coreDataChatsManager.getChatIndex(by: chatIdentifier) {
                self?.coreDataChatsManager.updateChatUnreadMessagesCount(at: index, count: count)
                self?.presenter?.chatUnreadMessagesCountUpdated(chatIdentifier: chatIdentifier, count: count)
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
                self?.coreDataChatsManager.removeChat(at: index)
                self?.presenter?.chatRemoved(chatIdentifier: chatIdentifier)
            }
        } pairChatUpdated: { [weak self] chatIdentifier, companion in
            if let index = self?.coreDataChatsManager.getChatIndex(by: chatIdentifier) {
                self?.coreDataChatsManager.updateChatCompanion(at: index, companion: companion)
                self?.presenter?.chatCompanionUpdated(chatIdentifier: chatIdentifier, companion: companion)
            }
        } groupChatUpdated: { chatIdentifier, group in

        } chatLatestMessageUpdated: { [weak self] chatIdentifier, message in
            if let index = self?.coreDataChatsManager.getChatIndex(by: chatIdentifier) {
                self?.coreDataChatsManager.updateChatLatestMessage(at: index, message: message)
                self?.presenter?.chatMessageUpdated(chatIdentifier: chatIdentifier, message: message)
            }
        } chatUnreadMessagesUpdated: { [weak self] chatIdentifier, count in
            if let index = self?.coreDataChatsManager.getChatIndex(by: chatIdentifier) {
                self?.coreDataChatsManager.updateChatUnreadMessagesCount(at: index, count: count)
                self?.presenter?.chatUnreadMessagesCountUpdated(chatIdentifier: chatIdentifier, count: count)
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
