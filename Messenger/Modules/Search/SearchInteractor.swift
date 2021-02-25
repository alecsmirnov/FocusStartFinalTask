//
//  SearchInteractor.swift
//  Messenger
//
//  Created by Admin on 27.11.2020.
//

protocol ISearchInteractor: AnyObject {
    func fetchUsers()
}

protocol ISearchInteractorOutput: AnyObject {
    func fetchUsersSuccess(_ users: [UserInfo])
    func fetchUsersFail()
}

final class SearchInteractor {
    weak var presenter: ISearchInteractorOutput?
}

// MARK: - ISearchInteractor

extension SearchInteractor: ISearchInteractor {
    func fetchUsers() {
        guard let userIdentifier = FirebaseAuthService.currentUser()?.uid else { return }
        
        FirebaseUserService.fetchUsers { users in
            guard let users = users else {
                self.presenter?.fetchUsersFail()
                
                return
            }
            
            self.presenter?.fetchUsersSuccess(users.filter { $0.identifier != userIdentifier })
        }
    }
}
