//
//  FirebaseMenuManager.swift
//  Messenger
//
//  Created by Admin on 20.12.2020.
//

final class FirebaseMenuManager {
    private var observedUser: ObserverData?
}

// MARK: - Public Editing Methods

extension FirebaseMenuManager {
    func removeUser() {
        observedUser?.remove()
    }
}

// MARK: - Public Observe Methods

extension FirebaseMenuManager {
    func observeUser(userIdentifier: String, completion: @escaping (UserInfo) -> Void) {
        observedUser = FirebaseUserService.observeUserChanged(userIdentifier: userIdentifier, completion: completion)
    }
}

// MARK: - Public Fetch Methods

extension FirebaseMenuManager {
    func fetchUser(userIdentifier: String, completion: @escaping (UserInfo?) -> Void) {
        FirebaseUserService.fetchUser(userIdentifier: userIdentifier, completion: completion)
    }
}
