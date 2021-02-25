//
//  FirebaseChatLogManager.swift
//  Messenger
//
//  Created by Admin on 21.12.2020.
//

import Foundation

final class FirebaseChatLogManager {
    private var observedCompanion: ObserverData?
    private var observedAddedMessages: ObserverData?
}

// MARK: - Public Editing Methods

extension FirebaseChatLogManager {
    func removeCompanion() {
        observedCompanion?.remove()
    }
    
    func removeAddedMessages() {
        observedAddedMessages?.remove()
    }
}

// MARK: - Public Observe Methods

extension FirebaseChatLogManager {
    func observeCompanion(userIdentifier: String, completion: @escaping (UserInfo) -> Void) {
        observedCompanion = FirebaseUserService.observeUserChanged(
            userIdentifier: userIdentifier,
            completion: completion)
    }
    
    func observeAddedMessages(
        chatIdentifier: String,
        userIdentifier: String,
        latestUpdateTime: TimeInterval,
        limit: Int,
        completion: @escaping (MessageInfo) -> Void
    ) {
        observedAddedMessages = FirebaseMessageService.observeAddedMessages(
            chatIdentifier: chatIdentifier,
            userIdentifier: userIdentifier,
            latestUpdateTime: latestUpdateTime,
            limit: limit,
            completion: completion)
    }
}

// MARK: - Public Fetch Methods

extension FirebaseChatLogManager {
    func fetchCompanion(userIdentifier: String, completion: @escaping (UserInfo?) -> Void) {
        FirebaseUserService.fetchUser(userIdentifier: userIdentifier, completion: completion)
    }
}
