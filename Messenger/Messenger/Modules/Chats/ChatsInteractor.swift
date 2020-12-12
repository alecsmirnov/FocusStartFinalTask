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
    
    // TODO: renaming
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
            
            observeCompanionsChanged(for: userIdentifier)
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
            
            FirebaseDatabaseService.observeUserChanged(userIdentifier: chat.userIdentifier) { user in
                if let user = user?.first {
                    self?.presenter?.updateUser(user.value, userIdentifier: user.key)
                }
            }
            
            self?.presenter?.addChat(chat)
        }
    
        FirebaseDatabaseService.observeRemovedChats(for: userIdentifier) { [weak self] chatIdentifier in
            self?.presenter?.removeChat(chatIdentifier)
        }
    }
    
    func observeCompanionsChanged(for userIdentifier: String) {
        FirebaseDatabaseService.observeUserCompanionsChanged(userIdentifier: userIdentifier) { [weak self] user in
            if let user = user?.first {
                self?.presenter?.updateUser(user.value, userIdentifier: user.key)
            }
        }
    }
    
    func observeChatsLatestMessagesChanged(for userIdentifier: String) {
        FirebaseDatabaseService.observeChatsLatestMessagesChanged(for: userIdentifier) { [weak self] message in
            if let message = message?.first {
                self?.presenter?.updateChatMessage(message.value, chatIdentifier: message.key)
            }
        }
    }
}
