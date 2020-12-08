//
//  ChatsAssembly.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

enum ChatsAssembly {
    static func createChatsViewController() -> ChatsViewController {
        let viewController = ChatsViewController()
        
        let interactor = ChatsInteractor()
        let presenter = ChatsPresenter()
        let router = ChatsRouter(viewController: viewController)
        
        viewController.presenter = presenter
        
        interactor.presenter = presenter
        
        presenter.viewController = viewController
        presenter.interactor = interactor
        presenter.router = router
        
        return viewController
    }
}
