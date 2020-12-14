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
    func chatMessageUpdated(chatIdentifier: String, message: LatestMessageInfo)
    func chatUnreadMessagesCountUpdated(chatIdentifier: String, count: Int)
}

final class ChatsInteractor {
    weak var presenter: IChatsInteractorOutput?
    
    private let coreDataChatsManager = CoreDataChatsManager()
    private let firebaseChatsManager = FirebaseDatabaseChatsManager()
}

// MARK: - IChatsInteractor

extension ChatsInteractor: IChatsInteractor {
    func fetchChats() {
        guard let userIdentifier = FirebaseAuthService.currentUser()?.uid else { return }
        
        //
        coreDataChatsManager.resetUpdateTimestamp()
        //
        //coreDataChatsManager.removeChat(at: 0)
        loadStoredChats()
        
        let latestUpdateTime = coreDataChatsManager.getLatestUpdateTimestamp()
        
        print("update time: \(latestUpdateTime)")
        print("chats count: \(coreDataChatsManager.getChats().count)")
        


        firebaseChatsManager.observeChats(userIdentifier: userIdentifier,
                                          latestUpdateTime: latestUpdateTime) { [weak self] chat in
            self?.coreDataChatsManager.appendChat(chat: chat)

            self?.presenter?.chatAdded(chat: chat)
            print("add")
        } chatRemovedCompletion: { [weak self] chatIdentifier in
            // Oops
            //self?.coreDataChatsManager.removeChat(at: index)

            self?.presenter?.chatRemoved(chatIdentifier: chatIdentifier)
        } pairChatUpdated: { [weak self] chatIdentifier, companion in
            // Oooooops
            //self?.coreDataChatsManager.updateChat(at: index, with: chat)

            self?.presenter?.chatCompanionUpdated(chatIdentifier: chatIdentifier, companion: companion)
        } groupChatUpdated: { chatIdentifier, group in

        } chatLatestMessageUpdated: { [weak self] chatIdentifier, message in
            // Oooooops
            //self?.coreDataChatsManager.updateChat(at: index, with: chat)

            self?.presenter?.chatMessageUpdated(chatIdentifier: chatIdentifier, message: message)
        } chatUnreadMessagesUpdated: { [weak self] chatIdentifier, count in
            // Oooooops
            //self?.coreDataChatsManager.updateChat(at: index, with: chat)

            self?.presenter?.chatUnreadMessagesCountUpdated(chatIdentifier: chatIdentifier, count: count)
        }
    }
}

private extension ChatsInteractor {
    func loadStoredChats() {
        let storedChats = coreDataChatsManager.getChats()
        
        if !storedChats.isEmpty {
            presenter?.fetchChatsSuccess(chats: storedChats)
        }
    }
    
    func test() {
        //coreDataChatsManager.getLatestUpdateTimestamp()
    }
}
