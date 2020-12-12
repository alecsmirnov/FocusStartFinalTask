//
//  ChatsPresenter.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

import Dispatch

protocol IChatsPresenter: AnyObject {
    var chatsCount: Int { get }

    func viewDidLoad()
    
    func chat(forRowAt index: Int) -> FirebaseChat?
    
    func didPressMenuButton()
    func didSelectChatAt(index: Int)
    func didPressSearchButton()
}

final class ChatsPresenter {
    // MARK: Properties
    
    weak var viewController: IChatsViewController?
    var interactor: IChatsInteractor?
    var router: IChatsRouter?
    
    private var chats = [FirebaseChat]()
}

// MARK: - IChatsPresenter

extension ChatsPresenter: IChatsPresenter {
    func viewDidLoad() {        
        interactor?.fetchChats()
    }
    
    var chatsCount: Int {
        return chats.count
    }
    
    func chat(forRowAt index: Int) -> FirebaseChat? {
        return chats[index]
    }
    
    func didSelectChatAt(index: Int) {
        let user = UserInfo(identifier: chats[index].userIdentifier,
                            firstName: chats[index].user.firstName,
                            lastName: chats[index].user.lastName,
                            email: chats[index].user.email,
                            profilePhotoURL: chats[index].user.profilePhotoURL)

        router?.openChatLogViewController(with: user, chatIdentifier: chats[index].chatIdentifier)
    }
    
    func didPressSearchButton() {
        router?.openSearchViewController(delegate: self)
    }
    
    func didPressMenuButton() {
        router?.openMenuViewController()
    }
}

// MARK: - IChatsInteractorOutput

extension ChatsPresenter: IChatsInteractorOutput {
    func fetchChatsSuccess(_ chats: [FirebaseChat]) {
        self.chats = chats
        
        viewController?.reloadData()
    }
    
    func fetchChatsFail() {
        // TODO: fail display
    }
    
    func addChat(_ chat: FirebaseChat) {
        chats.append(chat)
        
        viewController?.reloadData()
    }
    
    func removeChat(_ chatIdentifier: String) {
        if let index = chats.firstIndex(where: { $0.chatIdentifier == chatIdentifier }) {
            chats.remove(at: index)
            
            viewController?.reloadData()
        }
    }
    
    func updateUser(_ user: UsersValue, userIdentifier: String) {
        if let index = chats.firstIndex(where: { $0.userIdentifier == userIdentifier }) {
            chats[index].user = user
            
            viewController?.reloadData()
        }
    }
    
    func updateChatMessage(_ message: ChatsMessagesValue, chatIdentifier: String) {
        if let index = chats.firstIndex(where: { $0.chatIdentifier == chatIdentifier }) {
            chats[index].latestMessage = message
            
            viewController?.reloadData()
        }
    }
}

// MARK: - ISearchPresenterDelegate

extension ChatsPresenter: ISearchPresenterDelegate {
    func iSearchPresenter(_ searchPresenter: ISearchPresenter, didSelectUser user: UserInfo) {
        var chatIdentifier: String?
        
        if let index = chats.firstIndex(where: { $0.userIdentifier == user.identifier }) {
            chatIdentifier = chats[index].chatIdentifier
        }
        
        router?.openChatLogViewController(with: user, chatIdentifier: chatIdentifier)
    }
}
