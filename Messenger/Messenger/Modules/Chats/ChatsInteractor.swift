//
//  ChatsInteractor.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

protocol IChatsInteractor: AnyObject {
    func fetchChats()
}

protocol IChatsInteractorOutput: AnyObject {
    func fetchChatsSuccess(_ chats: [FirebaseChat])
    func fetchChatsFail()
    
    func addChat(_ chat: FirebaseChat)
    
    func removeChat(_ chatIdentifier: String)
    
    // TODO: change user and message structure
    func updateUser(_ user: UsersValue, userIdentifier: String)
    func updateChatMessage(_ message: ChatsMessagesValue, chatIdentifier: String)
}

final class ChatsInteractor {
    weak var presenter: IChatsInteractorOutput?
}

// MARK: - IChatsInteractor

extension ChatsInteractor: IChatsInteractor {
    func fetchChats() {
        if let userIdentifier = FirebaseAuthService.currentUser()?.uid {
            fetchChats(for: userIdentifier)
            
            observeUsersChanged(for: userIdentifier)
            observeChatsLatestMessagesChanged(for: userIdentifier)
            
            observeChats(for: userIdentifier)
        }
    }
}

// MARK: - Private Methods

private extension ChatsInteractor {
    func fetchChats(for userIdentifier: String) {
        FirebaseDatabaseService.fetchChats(for: userIdentifier) { [weak self] chats, error in
            guard let chats = chats, error == nil else {
                if let error = error, error != .chatNotFound {
                    var errorMessage: String?

                    switch error {
                    case .userNotFound: errorMessage = "user not found"
                    case .messageNotFound: errorMessage = "message not found"
                    case .latestMessageNotFound: errorMessage = "latest message not found"
                    default: break
                    }

                    if let errorMessage = errorMessage {
                        LoggingService.log(category: .chats, layer: .presenter, type: .error, with: errorMessage)
                    }
                } else {
                    self?.presenter?.fetchChatsFail()
                }

                return
            }

            self?.presenter?.fetchChatsSuccess(chats)
        }
    }
    
    func observeChats(for userIdentifier: String) {
        FirebaseDatabaseService.observeAddedChats(for: userIdentifier) { [weak self] chat, error in
            guard let chat = chat, error == nil else {
                return
            }
            
            self?.presenter?.addChat(chat)
        }
    
        FirebaseDatabaseService.observeRemovedChats(for: userIdentifier) { [weak self] chatIdentifier in
            self?.presenter?.removeChat(chatIdentifier)
        }
    }
    
    func observeUsersChanged(for userIdentifier: String) {
        FirebaseDatabaseService.observeUsersChanged(for: userIdentifier) { [weak self] firebaseUser in
            if let firebaseUser = firebaseUser?.first {
                self?.presenter?.updateUser(firebaseUser.value, userIdentifier: firebaseUser.key)
            }
        }
    }
    
    func observeChatsLatestMessagesChanged(for userIdentifier: String) {
        FirebaseDatabaseService.observeChatsLatestMessagesChanged(for: userIdentifier) { [weak self] firebaseMessage in
            if let firebaseMessage = firebaseMessage?.first {
                self?.presenter?.updateChatMessage(firebaseMessage.value, chatIdentifier: firebaseMessage.key)
            }
        }
    }
}
