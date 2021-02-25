//
//  SearchAssembly.swift
//  Messenger
//
//  Created by Admin on 27.11.2020.
//

enum SearchAssembly {
    static func createSearchViewController(delegate: ISearchPresenterDelegate? = nil) -> SearchViewController {
        let viewController = SearchViewController()
        
        let interactor = SearchInteractor()
        let presenter = SearchPresenter()
        let router = SearchRouter(viewController: viewController)
        
        viewController.presenter = presenter
        
        interactor.presenter = presenter
        
        presenter.viewController = viewController
        presenter.interactor = interactor
        presenter.router = router
        
        presenter.delegate = delegate
        
        return viewController
    }
}
