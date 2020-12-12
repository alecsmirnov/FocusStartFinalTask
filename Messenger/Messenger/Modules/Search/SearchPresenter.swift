//
//  SearchPresenter.swift
//  Messenger
//
//  Created by Admin on 27.11.2020.
//

import Dispatch

protocol ISearchPresenter: AnyObject {
    var usersCount: Int { get }
    
    func viewDidLoad()
    
    func user(forRowAt index: Int) -> UserData
    
    func didChangeText(_ text: String)
    func didSelectUserAt(index: Int)
    
    func didPressCloseButton()
}

protocol ISearchPresenterDelegate: AnyObject {
    func iSearchPresenter(_ searchPresenter: ISearchPresenter, didSelectUser user: UserData)
}

final class SearchPresenter {
    // MARK: Properties
    
    weak var viewController: ISearchViewController?
    var interactor: ISearchInteractor?
    var router: ISearchRouter?
    
    weak var delegate: ISearchPresenterDelegate?
    
    private enum Constants {
        static let searchIndicationDelay = 0.8
    }
    
    private var isSearchExecuted = false
    
    private var users = [UserData]()
    private var filteredUsers = [UserData]()
}

// MARK: - ISearchPresenter

extension SearchPresenter: ISearchPresenter {
    var usersCount: Int {
        return filteredUsers.count
    }
    
    func viewDidLoad() {
        interactor?.fetchUsers()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.searchIndicationDelay) {
            if !self.isSearchExecuted {
                self.viewController?.showSpinnerView()
            }
        }
    }
    
    func user(forRowAt index: Int) -> UserData {
        return filteredUsers[index]
    }
    
    func didChangeText(_ text: String) {
        search(by: text)
    }
    
    func didSelectUserAt(index: Int) {
        router?.closeSearchViewController()
        delegate?.iSearchPresenter(self, didSelectUser: users[index])
    }
    
    func didPressCloseButton() {
        router?.closeSearchViewController()
    }
}

// MARK: - Private Methods

private extension SearchPresenter {
    func search(by name: String) {
        filteredUsers = users
        
        viewController?.hideNoResultLabel()
        viewController?.reloadData()
       
        if !name.isEmpty {
            filteredUsers = users.filter { user in
                let userName = "\(user.firstName) \(user.lastName ?? "")".lowercased()
                let searchName = name.lowercased()
                
                return userName.contains(searchName)
            }
            
            if filteredUsers.isEmpty {
                viewController?.showNoResultLabel()
            }
            
            viewController?.reloadData()
        }
    }
}

// MARK: - ISearchInteractorOutput

extension SearchPresenter: ISearchInteractorOutput {
    func fetchUsersSuccess(_ users: [UserData]) {
        self.users = users
        filteredUsers = users
        
        isSearchExecuted = true
        
        viewController?.hideSpinnerView()
        viewController?.reloadData()
    }
    
    func fetchUsersFail() {
        isSearchExecuted = true
        
        viewController?.hideSpinnerView()
        viewController?.showNoResultLabel()
    }
}
