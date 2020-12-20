//
//  MenuInteractor.swift
//  Messenger
//
//  Created by Admin on 07.12.2020.
//

import Foundation

protocol IMenuInteractor: AnyObject {
    func fetchUser() 
    
    func signOut()
}

protocol IMenuInteractorOutput: AnyObject {
    func fetchUserSuccess(_ user: UserInfo)
    func fetchUserFail()
}

final class MenuInteractor {
    weak var presenter: IMenuInteractorOutput?
    
    private let firebaseMenuManager = FirebaseMenuManager()
}

// MARK: - IMenuInteractor

extension MenuInteractor: IMenuInteractor {
    func fetchUser() {
        guard let userIdentifier = FirebaseAuthService.currentUser()?.uid else { return }
        
        firebaseMenuManager.fetchUser(userIdentifier: userIdentifier) { [weak self] user in
            guard let user = user else { return }
            
            self?.firebaseMenuManager.observeUser(userIdentifier: userIdentifier) { updatedUser in
                self?.presenter?.fetchUserSuccess(updatedUser)
            }
            
            self?.presenter?.fetchUserSuccess(user)
        }
    }
    
    func signOut() {
        sendSignOutNotification()
        
        FirebaseAuthService.signOut()
    }
}

// MARK: - Private Methods

extension MenuInteractor {
    func sendSignOutNotification() {
        NotificationCenter.default.post(name: .SignOut, object: nil)
    }
}
