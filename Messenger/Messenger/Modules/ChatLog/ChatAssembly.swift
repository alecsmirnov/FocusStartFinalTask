//
//  ChatAssembly.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

enum ChatAssembly {
    static func createChatViewController() -> ChatViewController {
        let viewController = ChatViewController()
        
        let interactor = ChatInteractor()
        let presenter = ChatPresenter()
        let router = ChatRouter(viewController: viewController)
        
        viewController.presenter = presenter
        
        interactor.presenter = presenter
        
        presenter.viewController = viewController
        presenter.interactor = interactor
        presenter.router = router
        
        return viewController
    }
}
