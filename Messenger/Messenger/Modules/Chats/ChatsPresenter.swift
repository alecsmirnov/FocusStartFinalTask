//
//  ChatsPresenter.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

protocol IChatsPresenter: AnyObject {
    var chatsCount: Int { get }

    func viewDidLoad()
    func viewWillAppear()
    
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
    
    private var chats: [FirebaseChat]?
}

// MARK: - IChatsPresenter

extension ChatsPresenter: IChatsPresenter {
    func viewDidLoad() {
        interactor?.fetchChats()
    }
    
    func viewWillAppear() {

    }
    
    var chatsCount: Int {
        return chats?.count ?? 0
    }
    
    func chat(forRowAt index: Int) -> FirebaseChat? {
        return chats?[index]
    }
    
    func didSelectChatAt(index: Int) {
        //router?.openChatViewController(with: item)
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
        
        print("success")
        viewController?.reloadData()
    }
    
    func fetchChatsFail() {
        
    }
    
    func addChat(_ chat: FirebaseChat) {
        print("add")
        
        chats?.append(chat)
        
        viewController?.reloadData()
    }
    
    func removeChat(_ chatIdentifier: String) {
        print("remove")
        
        if let index = chats?.firstIndex(where: { $0.chatIdentifier == chatIdentifier }) {
            chats?.remove(at: index)
            
            viewController?.reloadData()
        }
    }
    
    func updateUser(_ user: UsersValue, userIdentifier: String) {
        print("update user")
        
        if let index = chats?.firstIndex(where: { $0.userIdentifier == userIdentifier }) {
            chats?[index].user = user
            
            viewController?.reloadData()
        }
    }
    
    func updateChatMessage(_ message: ChatsMessagesValue, chatIdentifier: String) {
        print("update message")
        
        if let index = chats?.firstIndex(where: { $0.chatIdentifier == chatIdentifier }) {
            chats?[index].latestMessage = message
            
            viewController?.reloadData()
        }
    }
}

// MARK: - ISearchPresenterDelegate

extension ChatsPresenter: ISearchPresenterDelegate {
    func iSearchPresenter(_ searchPresenter: ISearchPresenter, didSelectUser user: UserData) {
        router?.openChatLogViewController(with: user)
    }
}
