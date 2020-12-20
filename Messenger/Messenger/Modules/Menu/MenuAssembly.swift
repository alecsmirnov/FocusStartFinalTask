//
//  MenuAssembly.swift
//  Messenger
//
//  Created by Admin on 07.12.2020.
//

enum MenuAssembly {
    static func createMenuViewController(
        menuChatsViewController: MenuChatsViewController? = nil
    ) -> MenuViewController {
        let viewController = MenuViewController()
        
        let interactor = MenuInteractor()
        let presenter = MenuPresenter()
        let router = MenuRouter(viewController: viewController, menuChatsViewController: menuChatsViewController)
        
        viewController.presenter = presenter
        
        interactor.presenter = presenter
        
        presenter.viewController = viewController
        presenter.interactor = interactor
        presenter.router = router
        
        return viewController
    }
}
