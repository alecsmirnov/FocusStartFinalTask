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
    
    //func chat(forRowAt index: Int) -> FirebaseChat?
    func chat(forRowAt index: Int) -> ChatInfo?
    
    func didPressMenuButton()
    func didSelectChatAt(index: Int)
    func didPressSearchButton()
}

final class ChatsPresenter {
    // MARK: Properties
    
    weak var viewController: IChatsViewController?
    var interactor: IChatsInteractor?
    var router: IChatsRouter?
    
    private var chats = [ChatInfo]()
    //private var chats = [FirebaseChat]()
}

// MARK: - IChatsPresenter

extension ChatsPresenter: IChatsPresenter {
    func viewDidLoad() {        
        interactor?.fetchChats()
    }
    
    var chatsCount: Int {
        return chats.count
    }
    
    //func chat(forRowAt index: Int) -> FirebaseChat? {
    func chat(forRowAt index: Int) -> ChatInfo? {
        return chats[index]
    }
    
    func didSelectChatAt(index: Int) {
//        let user = UserInfo(identifier: chats[index].companion.userIdentifier,
//                            firstName: chats[index].user.firstName,
//                            lastName: chats[index].user.lastName,
//                            email: chats[index].user.email,
//                            profilePhotoURL: chats[index].user.profilePhotoURL)
//
//        router?.openChatLogViewController(with: user, chatIdentifier: chats[index].chatIdentifier)
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
    func fetchChatsSuccess(chats: [ChatInfo]) {
        self.chats = chats
        
        print(chats)
        
        viewController?.reloadData()
    }
    
    func chatAdded(chat: ChatInfo) {
        chats.append(chat)
        
        viewController?.reloadData()
    }
    
    func chatRemoved(chatIdentifier: String) {
        if let index = chats.firstIndex(where: { $0.identifier == chatIdentifier }) {
            chats.remove(at: index)
            
            viewController?.reloadData()
        }
    }
    
    func chatCompanionUpdated(chatIdentifier: String, companion: UserInfo) {
        if let index = chats.firstIndex(where: { $0.identifier == chatIdentifier }) {
            chats[index].companion = companion
            
            viewController?.reloadData()
        }
    }
    
    func chatMessageUpdated(chatIdentifier: String, message: LatestMessageInfo) {
        if let index = chats.firstIndex(where: { $0.identifier == chatIdentifier }) {
            chats[index].latestMessage = message
            
            viewController?.reloadData()
        }
    }
    
    func chatUnreadMessagesCountUpdated(chatIdentifier: String, count: Int) {
        if let index = chats.firstIndex(where: { $0.identifier == chatIdentifier }) {
            chats[index].unreadMessagesCount = count
            
            viewController?.reloadData()
        }
    }
}

// MARK: - ISearchPresenterDelegate

extension ChatsPresenter: ISearchPresenterDelegate {
    func iSearchPresenter(_ searchPresenter: ISearchPresenter, didSelectUser user: UserInfo) {
       // var chatIdentifier: String?
        
//        if let index = chats.firstIndex(where: { $0.userIdentifier == user.identifier }) {
//            chatIdentifier = chats[index].chatIdentifier
//        }
//
//        router?.openChatLogViewController(with: user, chatIdentifier: chatIdentifier)
    }
}
