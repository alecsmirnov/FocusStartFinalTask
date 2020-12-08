//
//  SearchPresenter.swift
//  Messenger
//
//  Created by Admin on 27.11.2020.
//

protocol ISearchPresenter: AnyObject {
    var usersCount: Int { get }
    
    func user(forRowAt index: Int) -> SearchUser?
    
    func didChangeText(_ text: String)
    func didSelectUserAt(index: Int)
}

protocol ISearchPresenterDelegate: AnyObject {
    func iSearchPresenter(_ searchPresenter: ISearchPresenter, didSelectUser user: SearchUser)
}

final class SearchPresenter {
    // MARK: Properties
    
    weak var viewController: ISearchViewController?
    var interactor: ISearchInteractor?
    var router: ISearchRouter?
    
    weak var delegate: ISearchPresenterDelegate?
    
    private var users: [SearchUser]?
}

// MARK: - ISearchPresenter

extension SearchPresenter: ISearchPresenter {
    var usersCount: Int {
        return users?.count ?? 0
    }
    
    func user(forRowAt index: Int) -> SearchUser? {
        return users?[index]
    }
    
    func didChangeText(_ text: String) {
        search(by: text)
    }
    
    func didSelectUserAt(index: Int) {
        if let user = users?[index] {
            router?.closeSearchViewController()
            delegate?.iSearchPresenter(self, didSelectUser: user)
        }
    }
}

// MARK: - Helper Methods

private extension SearchPresenter {
    func search(by name: String) {
        users?.removeAll()
        
        viewController?.noResultLabelIsHidden = true
       
        if !name.isEmpty {
            viewController?.activityIndicatorViewIsHidden = false
    
            interactor?.fetchUsers(by: name)
        } else {
            viewController?.reloadData()
        }
    }
}

// MARK: - ISearchInteractorOutput

extension SearchPresenter: ISearchInteractorOutput {
    func fetchUsersSuccess(_ users: [SearchUser]) {
        self.users = users
        
        viewController?.activityIndicatorViewIsHidden = true
        viewController?.reloadData()
    }
    
    func fetchUsersFail() {
        viewController?.activityIndicatorViewIsHidden = true
        viewController?.noResultLabelIsHidden = false
    }
}
