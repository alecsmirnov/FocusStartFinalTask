//
//  ProfileAssembly.swift
//  Messenger
//
//  Created by Admin on 19.12.2020.
//

enum ProfileAssembly {
    static func createProfileViewController(with user: UserInfo?) -> ProfileViewController {
        let viewController = ProfileViewController()
        
        let interactor = ProfileInteractor()
        let presenter = ProfilePresenter()
        let router = ProfileRouter(viewController: viewController)
        
        viewController.presenter = presenter
        
        interactor.presenter = presenter
        
        presenter.viewController = viewController
        presenter.interactor = interactor
        presenter.router = router
        
        presenter.user = user
        
        return viewController
    }
}
