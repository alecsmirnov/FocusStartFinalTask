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
    
    private let firebaseSearchManager = FirebaseSearchManager()
}

// MARK: - ISearchInteractor

extension SearchInteractor: ISearchInteractor {
    func fetchUsers() {
        guard let userIdentifier = FirebaseAuthService.currentUser()?.uid else { return }
        
        firebaseSearchManager.fetchUsers { [weak self] users in
            guard let users = users?.filter({ $0.identifier != userIdentifier }), !users.isEmpty else {
                self?.presenter?.fetchUsersFail()

                return
            }
            
            self?.presenter?.fetchUsersSuccess(users)
        }
    }
}
