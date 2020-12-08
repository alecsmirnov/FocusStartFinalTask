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
    
    func chat(forRowAt index: Int) -> Chat?
    
    func didPressMenuButton()
    func didSelectChatAt(index: Int)
    func didPressSearchButton()
}

final class ChatsPresenter {
    // MARK: Properties
    
    weak var viewController: IChatsViewController?
    var interactor: IChatsInteractor?
    var router: IChatsRouter?
    
    private var chats: [Chat]?
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
    
    func chat(forRowAt index: Int) -> Chat? {
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
    func fetchChatsSuccess(_ chats: [Chat]) {
        self.chats = chats
        
        print("success")
        viewController?.reloadData()
    }
    
    func fetchChatsFail() {
        
    }
    
    func updateChatMessage(_ message: FirebaseMessage, chatIdentifier: String) {
        if let firstIndex = chats?.firstIndex(where: { $0.chatIdentifier == chatIdentifier }) {
            chats?[firstIndex].latestMessage = message
            
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
