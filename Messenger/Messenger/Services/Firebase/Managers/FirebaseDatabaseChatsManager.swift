//
//  FirebaseChatsManager.swift
//  Messenger
//
//  Created by Admin on 14.12.2020.
//

import FirebaseDatabase

final class FirebaseChatsManager {
    enum PairChatsError: Error {
        case chatCompanionNotFound
        case userNotFound
        case latestMessageNotFound
    }
    
    private enum Constants {
        static let timestampKey = "timestamp"
        static let timestampClearValue = -1.0
    }
    
    private let databaseReference = Database.database().reference()
    private var observedChatsData = [String: [ObserverData]]()
}

// MARK: - Public Editing Methods

extension FirebaseChatsManager {
    func clearChat(chatIdentifier: String, userIdentifier: String) {
        databaseReference.child(Tables.usersChatsMessages)
                         .child(userIdentifier)
                         .child(chatIdentifier)
                         .removeValue()
        
        let emptyChatLatestMessage = UsersChatsLatestMessageValue(timestamp: Constants.timestampClearValue)
        
        if let latestChatLatestMessageValue = FirebaseDatabaseCoding.toDictionary(emptyChatLatestMessage) {
            databaseReference.child(Tables.usersChatsLatestMessages)
                             .child(userIdentifier)
                             .child(chatIdentifier)
                             .setValue(latestChatLatestMessageValue)
        }
        
        let emptyUnreadMessagesCount = UsersChatsUnreadMessagesCountValue(timestamp: Constants.timestampClearValue)
        
        if let emptyUnreadMessagesCountValue = FirebaseDatabaseCoding.toDictionary(emptyUnreadMessagesCount) {
            databaseReference.child(Tables.usersChatsUnread)
                             .child(userIdentifier)
                             .child(chatIdentifier)
                             .setValue(emptyUnreadMessagesCountValue)
        }
    }
    
    func removeChat(chatIdentifier: String, userIdentifier: String) {
        if let chatObservers = observedChatsData[chatIdentifier] {
            chatObservers.forEach { $0.remove() }
        }
        
        databaseReference.child(Tables.usersChats)
                         .child(userIdentifier)
                         .child(chatIdentifier)
                         .removeValue()
        
        clearChat(chatIdentifier: chatIdentifier, userIdentifier: userIdentifier)
    }
}

// MARK: - Public Observe Methods

extension FirebaseChatsManager {
    func observeLoadedChats(userIdentifier: String,
                            latestUpdateTime: TimeInterval,
                            chats: [ChatInfo],
                            pairChatUpdated: @escaping (String, UserInfo) -> Void,
                            groupChatUpdated: @escaping (String, GroupInfo) -> Void,
                            chatLatestMessageUpdated: @escaping (String, MessageInfo?) -> Void,
                            chatUnreadMessagesUpdated: @escaping (String, Int) -> Void,
                            chatOnlineStatusUpdate: @escaping (String, Bool) -> Void) {
        chats.forEach { chat in
            if chat.isGroup {
                
            } else if let companion = chat.companion {
                fetchUserWithUpdateTime(userIdentifier: companion.identifier,
                                        latestUpdateTime: latestUpdateTime) { companion in
                    if let companion = companion {
                        pairChatUpdated(chat.identifier, companion)
                    }
                }

                fetchUserChatLatestMessageWithUpdateTime(chatIdentifier: chat.identifier,
                                                         userIdentifier: userIdentifier,
                                                         latestUpdateTime: latestUpdateTime) { latestMessage in
                    if let latestMessage = latestMessage {
                        chatLatestMessageUpdated(chat.identifier, latestMessage)
                    }
                }

                fetchChatUnreadMessagesCountWithUpdateTime(chatIdentifier: chat.identifier,
                                                           userIdentifier: userIdentifier,
                                                           latestUpdateTime: latestUpdateTime) { count in
                    if let count = count {
                        chatUnreadMessagesUpdated(chat.identifier, count)
                    }
                }
                
                FirebaseDatabaseUserStatusService.fetchUserStatus(userIdentifier: companion.identifier) { isOnline in
                    if let isOnline = isOnline {
                        chatOnlineStatusUpdate(chat.identifier, isOnline)
                    }
                }
                
                observePairChat(chatIdentifier: chat.identifier,
                                userIdentifier: userIdentifier,
                                companionIdentifier: companion.identifier,
                                pairChatUpdated: pairChatUpdated,
                                chatLatestMessageUpdated: chatLatestMessageUpdated,
                                chatUnreadMessagesUpdated: chatUnreadMessagesUpdated)
                
                let userStatusObserver = FirebaseDatabaseUserStatusService.observeUserStatus(
                    userIdentifier: companion.identifier
                ) { isOnline in
                    chatOnlineStatusUpdate(chat.identifier, isOnline)
                }
                
                observedChatsData[chat.identifier] = (observedChatsData[companion.identifier] ?? []) +
                                                     [userStatusObserver]
            }
        }
    }
    
    func observeChats(userIdentifier: String,
                      latestUpdateTime: TimeInterval,
                      chatAddedCompletion: @escaping (ChatInfo) -> Void,
                      pairChatUpdated: @escaping (String, UserInfo) -> Void,
                      groupChatUpdated: @escaping (String, GroupInfo) -> Void,
                      chatLatestMessageUpdated: @escaping (String, MessageInfo?) -> Void,
                      chatUnreadMessagesUpdated: @escaping (String, Int) -> Void,
                      chatOnlineStatusUpdate: @escaping (String, Bool) -> Void) {
        observeAddedChats(for: userIdentifier, latestUpdateTime: latestUpdateTime) { [weak self] chat in
            chatAddedCompletion(chat)
            
            if chat.isGroup {
                
            } else if let companion = chat.companion {
                self?.observePairChat(chatIdentifier: chat.identifier,
                                      userIdentifier: userIdentifier,
                                      companionIdentifier: companion.identifier,
                                      pairChatUpdated: pairChatUpdated,
                                      chatLatestMessageUpdated: chatLatestMessageUpdated,
                                      chatUnreadMessagesUpdated: chatUnreadMessagesUpdated)
                
                let userStatusObserver = FirebaseDatabaseUserStatusService.observeUserStatus(
                    userIdentifier: companion.identifier
                ) { isOnline in
                    chatOnlineStatusUpdate(chat.identifier, isOnline)
                }
                
                self?.observedChatsData[chat.identifier] = (self?.observedChatsData[companion.identifier] ?? []) +
                                                           [userStatusObserver]
            }
        }
    }
    
    func observeRemovedChats(for userIdentifier: String, completion: @escaping (String) -> Void) {
        databaseReference.child(Tables.usersChats)
                         .child(userIdentifier)
                         .observe(.childRemoved) { snapshot in
            completion(snapshot.key)
        }
    }
}

// MARK: - Private Observe Methods

private extension FirebaseChatsManager {
    func observePairChat(chatIdentifier: String,
                         userIdentifier: String,
                         companionIdentifier: String,
                         pairChatUpdated: @escaping (String, UserInfo) -> Void,
                         chatLatestMessageUpdated: @escaping (String, MessageInfo?) -> Void,
                         chatUnreadMessagesUpdated: @escaping (String, Int) -> Void) {
        let companionObserver = observeCompanionChanged(companionIdentifier: companionIdentifier) { companion in
            pairChatUpdated(chatIdentifier, companion)
        }
        
        let latestMessageObserver = observeLatestMessagesChanged(chatIdentifier: chatIdentifier,
                                                                 userIdentifier: userIdentifier) { message in
            chatLatestMessageUpdated(chatIdentifier, message)
        }
        
        let unreadMessagesObserver = observeUnreadMessagesChanged(chatIdentifier: chatIdentifier,
                                                                  userIdentifier: userIdentifier) { count in
            chatUnreadMessagesUpdated(chatIdentifier, count)
        }
        
        let observers = [companionObserver, latestMessageObserver, unreadMessagesObserver]
        
        observedChatsData[chatIdentifier] = (observedChatsData[chatIdentifier] ?? []) + observers
    }
    
    func observeCompanionChanged(companionIdentifier: String,
                                 completion: @escaping (UserInfo) -> Void) -> ObserverData {
        let companionReference = databaseReference.child(Tables.users).child(companionIdentifier)
        let companionHandle = companionReference.observe(.childChanged) { snapshot in
            guard let value = snapshot.value as? [String: Any],
                  let userValue = FirebaseDatabaseCoding.fromDictionary([snapshot.key: value],
                                                                        type: UsersValue.self) else { return }
            
            let userInfo = UserInfo(identifier: companionIdentifier,
                                    firstName: userValue.firstName,
                                    lastName: userValue.lastName,
                                    email: userValue.email,
                                    profileImageData: nil)
            
            completion(userInfo)
        }
        
        return ObserverData(reference: companionReference, handle: companionHandle)
    }
    
    func observeLatestMessagesChanged(chatIdentifier: String,
                                      userIdentifier: String,
                                      completion: @escaping (MessageInfo?) -> Void) -> ObserverData {
        let latestMessageReference = databaseReference.child(Tables.usersChatsLatestMessages)
                                                      .child(userIdentifier)
                                                      .child(chatIdentifier)
        let latestMessageHandle = latestMessageReference.observe(.childChanged) { [weak self] snapshot in
            guard let value = snapshot.value as? [String: Any],
                  let latestMessageValue = FirebaseDatabaseCoding.fromDictionary(
                      [snapshot.key: value],
                      type: UsersChatsLatestMessageValue.self
                  ),
                  let latestMessageIdentifier = latestMessageValue.identifier else {
                completion(nil)
                
                return
            }
            
            self?.fetchChatMessage(chatIdentifier: chatIdentifier,
                                   messageIdentifier: latestMessageIdentifier) { message in
                completion(message)
            }
        }
        
        return ObserverData(reference: latestMessageReference, handle: latestMessageHandle)
    }
    
    func observeUnreadMessagesChanged(chatIdentifier: String,
                                      userIdentifier: String,
                                      completion: @escaping (Int) -> Void) -> ObserverData {
        let unreadMessagesReference = databaseReference.child(Tables.usersChatsUnread)
                                                       .child(userIdentifier)
                                                       .child(chatIdentifier)
        let unreadMessagesHandle = unreadMessagesReference.observe(.childChanged) { snapshot in
            guard let value = snapshot.value as? [String: Any],
                  let latestMessageValue = FirebaseDatabaseCoding.fromDictionary(
                      [snapshot.key: value],
                      type: UsersChatsUnreadMessagesCountValue.self
                  ) else { return }

            completion(latestMessageValue.count)
        }
        
        return ObserverData(reference: unreadMessagesReference, handle: unreadMessagesHandle)
    }
    
    func observeAddedChats(for userIdentifier: String,
                           latestUpdateTime: TimeInterval,
                           completion: @escaping (ChatInfo) -> Void) {
        databaseReference.child(Tables.usersChats)
                         .child(userIdentifier)
                         .queryOrdered(byChild: Constants.timestampKey)
                         .queryStarting(atValue: latestUpdateTime)
                         .observe(.childAdded) { [weak self] snapshot in
            let chatIdentifier = snapshot.key
            
            self?.fetchGroupChatStatus(chatIdentifier: chatIdentifier) { isGroup in
                guard let isGroup = isGroup else { return }
                
                if isGroup {
                    
                } else {
                    self?.fetchPairChat(chatIdentifier: chatIdentifier,
                                        userIdentifier: userIdentifier) { chat, error in
                        guard let chat = chat, error == nil else {
                            LoggingService.log(category: .database,
                                               layer: .none,
                                               type: .error,
                                               with: error?.localizedDescription)
                            
                            return
                        }
                        
                        completion(chat)
                    }
                }
            }
        }
    }
}

// MARK: - Private Fetch Methods

private extension FirebaseChatsManager {
    func fetchPairChat(chatIdentifier: String,
                       userIdentifier: String,
                       completion: @escaping (ChatInfo?, PairChatsError?) -> Void) {
        fetchChatCompanionIdentifier(chatIdentifier: chatIdentifier,
                                     userIdentifier: userIdentifier) { [weak self] companionIdentifier in
            guard let companionIdentifier = companionIdentifier else {
                completion(nil, .chatCompanionNotFound)
                
                return
            }
            
            self?.fetchUser(userIdentifier: companionIdentifier) { companion in
                guard let companion = companion else {
                    completion(nil, .userNotFound)
                    
                    return
                }
                
                self?.fetchUserChatLatestMessage(chatIdentifier: chatIdentifier,
                                                 userIdentifier: userIdentifier) { latestMessage in
                    self?.fetchChatUnreadMessagesCount(chatIdentifier: chatIdentifier,
                                                       userIdentifier: userIdentifier) { unreadCount in
                        let chat = ChatInfo(identifier: chatIdentifier,
                                            isGroup: false,
                                            companion: companion,
                                            latestMessage: latestMessage,
                                            unreadMessagesCount: unreadCount)
                        
                        completion(chat, nil)
                    }
                }
            }
        }
    }
    
    func fetchUser(userIdentifier: String, completion: @escaping (UserInfo?) -> Void) {
        databaseReference.child(Tables.users)
                         .child(userIdentifier)
                         .observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any],
                  let userValue = FirebaseDatabaseCoding.fromDictionary(value, type: UsersValue.self) else {
                completion(nil)

                return
            }
                            
            let userInfo = UserInfo(identifier: userIdentifier,
                                    firstName: userValue.firstName,
                                    lastName: userValue.lastName,
                                    email: userValue.email,
                                    profileImageData: nil)
                            
            completion(userInfo)
        }
    }
    
    func fetchUserWithUpdateTime(userIdentifier: String,
                                 latestUpdateTime: TimeInterval,
                                 completion: @escaping (UserInfo?) -> Void) {
        databaseReference.child(Tables.users)
                         .child(userIdentifier)
                         .queryOrdered(byChild: Constants.timestampKey)
                         .queryStarting(atValue: latestUpdateTime)
                         .observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any],
                  let userValue = FirebaseDatabaseCoding.fromDictionary(value, type: UsersValue.self) else {
                completion(nil)

                return
            }

            let userInfo = UserInfo(identifier: userIdentifier,
                                    firstName: userValue.firstName,
                                    lastName: userValue.lastName,
                                    email: userValue.email,
                                    profileImageData: nil)

            completion(userInfo)
        }
    }
    
    func fetchGroupChatStatus(chatIdentifier: String, completion: @escaping (Bool?) -> Void) {
        databaseReference.child(Tables.chatsInfo)
                         .child(chatIdentifier)
                         .observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? Bool else {
                completion(nil)
                
                return
            }
            
            completion(value)
        }
    }
    
    func fetchChatCompanionIdentifier(chatIdentifier: String,
                                      userIdentifier: String,
                                      completion: @escaping (String?) -> Void) {
        fetchChatMembersIdentifiers(chatIdentifier: chatIdentifier) { membersIdentifiers in
            guard let memberIdentifier = membersIdentifiers?.filter({ $0 != userIdentifier }).first else {
                completion(nil)
                
                return
            }
            
            completion(memberIdentifier)
        }
    }
    
    func fetchChatMembersIdentifiers(chatIdentifier: String, completion: @escaping ([String]?) -> Void) {
        databaseReference.child(Tables.chatsMembers)
                         .child(chatIdentifier)
                         .observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil)
                
                return
            }
                            
            completion(value.map { $0.key })
        }
    }
    
    func fetchUserChatLatestMessage(chatIdentifier: String,
                                    userIdentifier: String,
                                    completion: @escaping (MessageInfo?) -> Void) {
        fetchChatLatestMessageIdentifier(chatIdentifier: chatIdentifier,
                                         userIdentifier: userIdentifier) { [weak self] latestMessageIdentifier in
            guard let latestMessageIdentifier = latestMessageIdentifier else {
                completion(nil)
                
                return
            }
            
            self?.fetchChatMessage(chatIdentifier: chatIdentifier,
                                   messageIdentifier: latestMessageIdentifier) { message in
                guard let message = message else {
                    completion(nil)
                    
                    return
                }
                
                completion(message)
            }
        }
    }
    
    func fetchUserChatLatestMessageWithUpdateTime(chatIdentifier: String,
                                                  userIdentifier: String,
                                                  latestUpdateTime: TimeInterval,
                                                  completion: @escaping (MessageInfo?) -> Void) {
        databaseReference.child(Tables.usersChatsLatestMessages)
                         .child(userIdentifier)
                         .child(chatIdentifier)
                         .queryOrdered(byChild: Constants.timestampKey)
                         .queryStarting(atValue: latestUpdateTime)
                         .observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let value = snapshot.value as? [String: Any],
                  let userChatLatestMessageValue = FirebaseDatabaseCoding.fromDictionary(
                    value,
                    type: UsersChatsLatestMessageValue.self
                  ),
                  let latestMessageIdentifier = userChatLatestMessageValue.identifier else {
                completion(nil)
                
                return
            }
            
            self?.fetchChatMessage(chatIdentifier: chatIdentifier,
                                   messageIdentifier: latestMessageIdentifier) { message in
                guard let message = message else {
                    completion(nil)
                    
                    return
                }
                
                completion(message)
            }
        }
    }
    
    func fetchChatMessage(chatIdentifier: String,
                          messageIdentifier: String,
                          completion: @escaping (MessageInfo?) -> Void) {
        databaseReference.child(Tables.chatsMessages)
                               .child(chatIdentifier)
                               .child(messageIdentifier)
                               .observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any],
                  let messageValue = FirebaseDatabaseCoding.fromDictionary(value, type: ChatsMessagesValue.self) else {
                completion(nil)
                
                return
            }
    
            
            let message = MessageInfo(identifier: messageIdentifier,
                                      senderIdentifier: messageValue.senderIdentifier,
                                      type: messageValue.messageType,
                                      isRead: messageValue.isRead,
                                      timestamp: messageValue.timestamp)
            completion(message)
        }
    }
    
    func fetchChatLatestMessageIdentifier(chatIdentifier: String,
                                          userIdentifier: String,
                                          completion: @escaping (String?) -> Void) {
        databaseReference.child(Tables.usersChatsLatestMessages)
                         .child(userIdentifier)
                         .child(chatIdentifier)
                         .observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any],
                  let latestMessageValue = FirebaseDatabaseCoding.fromDictionary(
                      value,
                      type: UsersChatsLatestMessageValue.self
                  ) else {
                completion(nil)
                
                return
            }
                            
            completion(latestMessageValue.identifier)
        }
    }
    
    func fetchChatUnreadMessagesCount(chatIdentifier: String,
                                      userIdentifier: String,
                                      completion: @escaping (Int?) -> Void) {
        databaseReference.child(Tables.usersChatsUnread)
                         .child(userIdentifier)
                         .child(chatIdentifier)
                         .observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any],
                  let unreadMessage = FirebaseDatabaseCoding.fromDictionary(
                      value,
                      type: UsersChatsUnreadMessagesCountValue.self
                  ) else {
                completion(nil)

                return
            }

            completion(unreadMessage.count)
        }
    }
    
    func fetchChatUnreadMessagesCountWithUpdateTime(chatIdentifier: String,
                                                    userIdentifier: String,
                                                    latestUpdateTime: TimeInterval,
                                                    completion: @escaping (Int?) -> Void) {
        databaseReference.child(Tables.usersChatsUnread)
                         .child(userIdentifier)
                         .child(chatIdentifier)
                         .queryOrdered(byChild: Constants.timestampKey)
                         .queryStarting(atValue: latestUpdateTime)
                         .observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any],
                  let unreadMessage = FirebaseDatabaseCoding.fromDictionary(
                      value,
                      type: UsersChatsUnreadMessagesCountValue.self
                  ) else {
                completion(nil)
                
                return
            }
            
            completion(unreadMessage.count)
        }
    }
}
