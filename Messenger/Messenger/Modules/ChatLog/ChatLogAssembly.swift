//
//  ChatLogAssembly.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

enum ChatLogAssembly {
    static func createChatLogViewController(with companion: UserInfo) -> ChatLogViewController {
        let viewController = ChatLogViewController()
        
        let interactor = ChatLogInteractor()
        let presenter = ChatLogPresenter()
        
        viewController.presenter = presenter
        
        interactor.presenter = presenter
        
        presenter.viewController = viewController
        presenter.interactor = interactor
        
        interactor.initPairChat(with: companion)
        
        return viewController
    }
    
    static func createChatLogViewController(with chat: ChatInfo) -> ChatLogViewController {
        let viewController = ChatLogViewController()
        
        let interactor = ChatLogInteractor()
        let presenter = ChatLogPresenter()
        
        viewController.presenter = presenter
        
        interactor.presenter = presenter
        
        presenter.viewController = viewController
        presenter.interactor = interactor
        
        interactor.initGroupChat(chat: chat)
        
        return viewController
    }
}
