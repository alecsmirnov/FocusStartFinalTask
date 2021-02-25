//
//  FirebaseChatsService.swift
//  Messenger
//
//  Created by Admin on 19.12.2020.
//

import FirebaseDatabase

enum FirebaseChatsService {
    enum PairChatsError: Error {
        case chatCompanionNotFound
        case userNotFound
        case latestMessageNotFound
    }
    
    private static let databaseReference = Database.database().reference()
}

// MARK: - Public Editing Methods

extension FirebaseChatsService {
    static func isChatExist(chatIdentifier: String, userIdentifier: String, completion: @escaping (Bool) -> Void) {
        databaseReference
            .child(Tables.usersChats)
            .child(userIdentifier)
            .child(chatIdentifier)
            .observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }

    static func createPairChat(chatIdentifier: String, userIdentifier1: String, userIdentifier2: String) {
        addChatMember(chatIdentifier: chatIdentifier, memberIdentifier: userIdentifier1)
        addChatMember(chatIdentifier: chatIdentifier, memberIdentifier: userIdentifier2)
    }
    
    static func addChatMember(chatIdentifier: String, memberIdentifier: String) {
        databaseReference.child(Tables.chatsMembers).child(chatIdentifier).child(memberIdentifier).setValue(true)

        databaseReference
            .child(Tables.usersChats)
            .child(memberIdentifier)
            .child(chatIdentifier)
            .child(Timestamp.key)
            .setValue(Timestamp.current)
    }
    
    static func clearChat(chatIdentifier: String, userIdentifier: String) {
        databaseReference.child(Tables.usersChatsMessages).child(userIdentifier).child(chatIdentifier).removeValue()
        
        let emptyChatLatestMessage = UsersChatsLatestMessageValue(timestamp: Timestamp.clearValue)
        
        if let latestChatLatestMessageValue = FirebaseDatabaseCoding.toDictionary(emptyChatLatestMessage) {
            databaseReference
                .child(Tables.usersChatsLatestMessages)
                .child(userIdentifier)
                .child(chatIdentifier)
                .setValue(latestChatLatestMessageValue)
        }
        
        let emptyUnreadMessagesCount = UsersChatsUnreadMessagesCountValue(timestamp: Timestamp.clearValue)
        
        if let emptyUnreadMessagesCountValue = FirebaseDatabaseCoding.toDictionary(emptyUnreadMessagesCount) {
            databaseReference
                .child(Tables.usersChatsUnread)
                .child(userIdentifier)
                .child(chatIdentifier)
                .setValue(emptyUnreadMessagesCountValue)
        }
    }
    
    static func removeChat(chatIdentifier: String, userIdentifier: String) {        
        databaseReference.child(Tables.usersChats).child(userIdentifier).child(chatIdentifier).removeValue()
        
        clearChat(chatIdentifier: chatIdentifier, userIdentifier: userIdentifier)
    }
}

// MARK: - Observe

extension FirebaseChatsService {
    static func observeLatestMessagesChanged(
        chatIdentifier: String,
        userIdentifier: String,
        completion: @escaping (MessageInfo?) -> Void
    ) -> ObserverData {
        let latestMessageReference = databaseReference
            .child(Tables.usersChatsLatestMessages)
            .child(userIdentifier)
            .child(chatIdentifier)
        let latestMessageHandle = latestMessageReference.observe(.childChanged) { snapshot in
            guard
                let value = snapshot.value as? [String: Any],
                let latestMessageValue = FirebaseDatabaseCoding.fromDictionary(
                    [snapshot.key: value],
                    type: UsersChatsLatestMessageValue.self),
                let latestMessageIdentifier = latestMessageValue.identifier
            else {
                completion(nil)
                
                return
            }
            
            FirebaseMessageService.fetchChatMessage(
                chatIdentifier: chatIdentifier,
                messageIdentifier: latestMessageIdentifier) { message in
                completion(message)
            }
        }
        
        return ObserverData(reference: latestMessageReference, handle: latestMessageHandle)
    }
    
    static func observeUnreadMessagesChanged(
        chatIdentifier: String,
        userIdentifier: String,
        completion: @escaping (Int) -> Void
    ) -> ObserverData {
        let unreadMessagesReference = databaseReference
            .child(Tables.usersChatsUnread)
            .child(userIdentifier)
            .child(chatIdentifier)
        let unreadMessagesHandle = unreadMessagesReference.observe(.childChanged) { snapshot in
            guard
                let value = snapshot.value as? [String: Any],
                let latestMessageValue = FirebaseDatabaseCoding.fromDictionary(
                    [snapshot.key: value],
                    type: UsersChatsUnreadMessagesCountValue.self)
            else {
                return
            }

            completion(latestMessageValue.count)
        }
        
        return ObserverData(reference: unreadMessagesReference, handle: unreadMessagesHandle)
    }
    
    static func observeAddedChats(
        for userIdentifier: String,
        latestUpdateTime: TimeInterval,
        completion: @escaping (ChatInfo) -> Void
    ) {
        databaseReference
            .child(Tables.usersChats)
            .child(userIdentifier)
            .queryOrdered(byChild: Timestamp.key)
            .queryStarting(atValue: latestUpdateTime)
            .observe(.childAdded) { snapshot in
            let chatIdentifier = snapshot.key
            
            fetchPairChat(
                chatIdentifier: chatIdentifier,
                userIdentifier: userIdentifier) { chat, error in
                guard var chat = chat, error == nil else {
                    LoggingService.log(
                        category: .database,
                        layer: .none,
                        type: .error,
                        with: error?.localizedDescription)
                    
                    return
                }
                
                if chat.latestMessage?.senderIdentifier != userIdentifier {
                    chat.isOnline = true
                }
                
                completion(chat)
            }
        }
    }
    
    static func observeRemovedChats(for userIdentifier: String, completion: @escaping (String) -> Void) {
        databaseReference.child(Tables.usersChats).child(userIdentifier).observe(.childRemoved) { snapshot in
            completion(snapshot.key)
        }
    }
}

// MARK: - Public Fetch Methods

extension FirebaseChatsService {
    static func fetchPairChat(
        chatIdentifier: String,
        userIdentifier: String,
        completion: @escaping (ChatInfo?, PairChatsError?) -> Void
    ) {
        fetchChatCompanionIdentifier(
            chatIdentifier: chatIdentifier,
            userIdentifier: userIdentifier) { companionIdentifier in
            guard let companionIdentifier = companionIdentifier else {
                completion(nil, .chatCompanionNotFound)
                
                return
            }
            
            FirebaseUserService.fetchUser(userIdentifier: companionIdentifier) { companion in
                guard let companion = companion else {
                    completion(nil, .userNotFound)
                    
                    return
                }
                
                fetchUserChatLatestMessage(
                    chatIdentifier: chatIdentifier,
                    userIdentifier: userIdentifier) { latestMessage in
                    fetchChatUnreadMessagesCount(
                        chatIdentifier: chatIdentifier,
                        userIdentifier: userIdentifier) { unreadCount in
                        let chat = ChatInfo(
                            identifier: chatIdentifier,
                            companion: companion,
                            latestMessage: latestMessage,
                            unreadMessagesCount: unreadCount)
                        
                        completion(chat, nil)
                    }
                }
            }
        }
    }
    
    static func fetchChatCompanionIdentifier(
        chatIdentifier: String,
        userIdentifier: String,
        completion: @escaping (String?) -> Void
    ) {
        fetchChatMembersIdentifiers(chatIdentifier: chatIdentifier) { membersIdentifiers in
            guard let memberIdentifier = membersIdentifiers?.filter({ $0 != userIdentifier }).first else {
                completion(nil)
                
                return
            }
            
            completion(memberIdentifier)
        }
    }
    
    static func fetchChatMembersIdentifiers(chatIdentifier: String, completion: @escaping ([String]?) -> Void) {
        databaseReference.child(Tables.chatsMembers).child(chatIdentifier).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil)
                
                return
            }
                            
            completion(value.map { $0.key })
        }
    }
    
    static func fetchUserChatLatestMessage(
        chatIdentifier: String,
        userIdentifier: String,
        completion: @escaping (MessageInfo?) -> Void
    ) {
        fetchChatLatestMessageIdentifier(
            chatIdentifier: chatIdentifier,
            userIdentifier: userIdentifier) { latestMessageIdentifier in
            guard let latestMessageIdentifier = latestMessageIdentifier else {
                completion(nil)
                
                return
            }
            
            FirebaseMessageService.fetchChatMessage(
                chatIdentifier: chatIdentifier,
                messageIdentifier: latestMessageIdentifier) { message in
                guard let message = message else {
                    completion(nil)
                    
                    return
                }
                
                completion(message)
            }
        }
    }
    
    static func fetchUserChatLatestMessageWithUpdateTime(
        chatIdentifier: String,
        userIdentifier: String,
        latestUpdateTime: TimeInterval,
        completion: @escaping (MessageInfo?) -> Void
    ) {
        databaseReference
            .child(Tables.usersChatsLatestMessages)
            .child(userIdentifier)
            .child(chatIdentifier)
            .queryOrdered(byChild: Timestamp.key)
            .queryStarting(atValue: latestUpdateTime)
            .observeSingleEvent(of: .value) { snapshot in
            guard
                let value = snapshot.value as? [String: Any],
                let userChatLatestMessageValue = FirebaseDatabaseCoding.fromDictionary(
                    value,
                    type: UsersChatsLatestMessageValue.self),
                let latestMessageIdentifier = userChatLatestMessageValue.identifier
            else {
                completion(nil)
                
                return
            }
                            
            FirebaseMessageService.fetchChatMessage(
                chatIdentifier: chatIdentifier,
                messageIdentifier: latestMessageIdentifier) { message in
                guard let message = message else {
                    completion(nil)
                    
                    return
                }
                
                completion(message)
            }
        }
    }
    
    static func fetchChatLatestMessageIdentifier(
        chatIdentifier: String,
        userIdentifier: String,
        completion: @escaping (String?) -> Void
    ) {
        databaseReference
            .child(Tables.usersChatsLatestMessages)
            .child(userIdentifier)
            .child(chatIdentifier)
            .observeSingleEvent(of: .value) { snapshot in
            guard
                let value = snapshot.value as? [String: Any],
                let latestMessageValue = FirebaseDatabaseCoding.fromDictionary(
                    value,
                    type: UsersChatsLatestMessageValue.self)
            else {
                completion(nil)
                
                return
            }
                            
            completion(latestMessageValue.identifier)
        }
    }
    
    static func fetchChatUnreadMessagesCount(
        chatIdentifier: String,
        userIdentifier: String,
        completion: @escaping (Int?) -> Void
    ) {
        databaseReference
            .child(Tables.usersChatsUnread)
            .child(userIdentifier)
            .child(chatIdentifier)
            .observeSingleEvent(of: .value) { snapshot in
            guard
                let value = snapshot.value as? [String: Any],
                let unreadMessage = FirebaseDatabaseCoding.fromDictionary(
                    value,
                    type: UsersChatsUnreadMessagesCountValue.self)
            else {
                completion(nil)

                return
            }

            completion(unreadMessage.count)
        }
    }
    
    static func fetchChatUnreadMessagesCountWithUpdateTime(
        chatIdentifier: String,
        userIdentifier: String,
        latestUpdateTime: TimeInterval,
        completion: @escaping (Int?) -> Void
    ) {
        databaseReference
            .child(Tables.usersChatsUnread)
            .child(userIdentifier)
            .child(chatIdentifier)
            .queryOrdered(byChild: Timestamp.key)
            .queryStarting(atValue: latestUpdateTime)
            .observeSingleEvent(of: .value) { snapshot in
            guard
                let value = snapshot.value as? [String: Any],
                let unreadMessage = FirebaseDatabaseCoding.fromDictionary(
                    value,
                    type: UsersChatsUnreadMessagesCountValue.self)
            else {
                completion(nil)
                
                return
            }
            
            completion(unreadMessage.count)
        }
    }
}

// MARK: - Helper Methods

extension FirebaseChatsService {
    static func getPairChatIdentifier(userIdentifier1: String, userIdentifier2: String) -> String {
        let chatIdentifier = (userIdentifier1 < userIdentifier2) ? userIdentifier1 + userIdentifier2 :
                                                                   userIdentifier2 + userIdentifier1
        return chatIdentifier
    }
}
