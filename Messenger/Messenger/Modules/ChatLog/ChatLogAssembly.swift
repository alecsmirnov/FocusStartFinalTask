//
//  ChatLogAssembly.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

enum ChatLogAssembly {
    static func createChatLogViewController(with user: UserInfo, chatIdentifier: String?) -> ChatLogViewController {
        let viewController = ChatLogViewController()
        
        let interactor = ChatLogInteractor()
        let presenter = ChatLogPresenter()
        let router = ChatLogRouter(viewController: viewController)
        
        viewController.presenter = presenter
        
        interactor.presenter = presenter
        
        presenter.viewController = viewController
        presenter.interactor = interactor
        presenter.router = router
        
        presenter.companion = user
        presenter.chatIdentifier = chatIdentifier
        
        return viewController
    }
}
