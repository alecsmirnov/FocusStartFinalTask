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
    func fetchChatsSuccess(_ chats: [Chat])
    func fetchChatsFail()
    
    func updateChatMessage(_ message: FirebaseMessage, chatIdentifier: String)
}

final class ChatsInteractor {
    weak var presenter: IChatsInteractorOutput?
}

// MARK: - IChatsInteractor

extension ChatsInteractor: IChatsInteractor {
    func fetchChats() {
        guard let userIdentifier = FirebaseAuthService.currentUser()?.uid else { return }
        
        FirebaseDatabaseService.fetchChats(for: userIdentifier) { [weak self] chats, error in
            guard let chats = chats, error == nil else {
                if let error = error {
                    switch error {
                    case .userNotFound: break
                    case .chatNotFound: break
                    case .messageNotFound: break
                    case .latestMessageNotFound: break
                    }
                }
                
                return
            }
            
            FirebaseDatabaseService.observeChatsMessages(for: userIdentifier) { firebaseMessage in
                if let firebaseMessage = firebaseMessage?.first {
                    self?.presenter?.updateChatMessage(firebaseMessage.value, chatIdentifier: firebaseMessage.key)
                }
            }
            
            self?.presenter?.fetchChatsSuccess(chats)
        }
    }
}
