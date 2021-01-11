//
//  RegistrationAssembly.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

enum RegistrationAssembly {
    static func createRegistrationViewController() -> RegistrationViewController {
        let viewController = RegistrationViewController()
        
        let interactor = RegistrationInteractor()
        let presenter = RegistrationPresenter()
        let router = RegistrationRouter(viewController: viewController)
        
        viewController.presenter = presenter
        
        interactor.presenter = presenter
        
        presenter.viewController = viewController
        presenter.interactor = interactor
        presenter.router = router
        
        return viewController
    }
}
