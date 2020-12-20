//
//  ChatsPresenter.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

protocol IChatsPresenter: AnyObject {
    var chatsCount: Int { get }

    func viewDidLoad()
    
    func chat(at index: Int) -> ChatInfo?
    
    func didSelectChat(at index: Int)
    func didClearChat(at index: Int)
    func didRemoveChat(at index: Int)
    
    func didPressMenuButton()
    func didPressSearchButton()
}

final class ChatsPresenter {
    weak var viewController: IChatsViewController?
    var interactor: IChatsInteractor?
    var router: IChatsRouter?
    
    private var chats = [ChatInfo]()
}

// MARK: - IChatsPresenter

extension ChatsPresenter: IChatsPresenter {
    func viewDidLoad() {
        interactor?.fetchChats()
    }
    
    var chatsCount: Int {
        return chats.count
    }
    
    func chat(at index: Int) -> ChatInfo? {
        return chats[index]
    }
    
    func didSelectChat(at index: Int) {
        router?.openChatLogViewController(with: chats[index])
    }
    
    func didClearChat(at index: Int) {
        interactor?.clearChat(at: index)
    }
    
    func didRemoveChat(at index: Int) {
        interactor?.removeChat(at: index)
    }
    
    func didPressMenuButton() {
        router?.extendMenu()
    }
    
    func didPressSearchButton() {
        router?.openSearchViewController(delegate: self)
    }
}

// MARK: - IChatsInteractorOutput

extension ChatsPresenter: IChatsInteractorOutput {
    func fetchChatsSuccess(_ chats: [ChatInfo]) {
        self.chats = chats
        
        viewController?.reloadData()
    }
    
    func chatAdded(_ chat: ChatInfo) {
        chats.append(chat)
        
        viewController?.reloadData()
    }
    
    func chatRemoved(at index: Int) {
        chats.remove(at: index)
        
        viewController?.reloadData()
    }
    
    func chatCompanionUpdated(at index: Int, companion: UserInfo) {
        chats[index].companion = companion
        
        viewController?.reloadData()
    }
    
    func chatMessageUpdated(at index: Int, message: MessageInfo?) {
        chats[index].latestMessage = message
        
        viewController?.reloadData()
    }
    
    func chatUnreadMessagesCountUpdated(at index: Int, count: Int) {
        chats[index].unreadMessagesCount = count
        
        viewController?.reloadData()
    }
    
    func chatOnlineStatusUpdate(at index: Int, isOnline: Bool) {
        chats[index].isOnline = isOnline
        
        viewController?.reloadData()
    }
}

// MARK: - ISearchPresenterDelegate

extension ChatsPresenter: ISearchPresenterDelegate {
    func iSearchPresenter(_ searchPresenter: ISearchPresenter, didSelectUser user: UserInfo) {
        router?.openChatLogViewController(with: user)
    }
}
