//
//  LoginAssembly.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

enum LoginAssembly {
    static func createLoginViewController() -> LoginViewController {
        let viewController = LoginViewController()
        
        let interactor = LoginInteractor()
        let presenter = LoginPresenter()
        let router = LoginRouter(viewController: viewController)
        
        viewController.presenter = presenter
        
        interactor.presenter = presenter
        
        presenter.viewController = viewController
        presenter.interactor = interactor
        presenter.router = router
        
        return viewController
    }
}
