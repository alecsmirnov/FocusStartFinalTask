//
//  SearchRouter.swift
//  Messenger
//
//  Created by Admin on 27.11.2020.
//

protocol ISearchRouter: AnyObject {
    func closeSearchViewController()
}

final class SearchRouter {
    // MARK: Properties
    
    private weak var viewController: SearchViewController?
    
    // MARK: Initialization
    
    init(viewController: SearchViewController) {
        self.viewController = viewController
    }
}

// MARK: - ISearchRouter

extension SearchRouter: ISearchRouter {
    func closeSearchViewController() {
        viewController?.dismiss(animated: true)
    }
}
