//
//  SearchInteractor.swift
//  Messenger
//
//  Created by Admin on 27.11.2020.
//

import Dispatch

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
        
        FirebaseDatabaseService.fetchUsers { users in
            guard let users = users?.filter({ $0.key != userIdentifier }), !users.isEmpty else {
                self.presenter?.fetchUsersFail()

                return
            }
            
            self.presenter?.fetchUsersSuccess(SearchInteractor.firebaseUsersToUsersData(users))
        }
    }
}

// MARK: - Private Methods

private extension SearchInteractor {
    static func firebaseUsersToUsersData(_ users: [String: UsersValue]) -> [UserInfo] {
        let usersData = users.map { identifier, user in
            return UserInfo(identifier: identifier,
                            firstName: user.firstName,
                            lastName: user.lastName,
                            email: user.email,
                            profileImageData: nil)
        }
        
        return usersData
    }
}
