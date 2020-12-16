//
//  FirebaseDatabaseChatsManager.swift
//  Messenger
//
//  Created by Admin on 14.12.2020.
//

import FirebaseDatabase

final class FirebaseDatabaseChatsManager {
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

fileprivate struct ObserverData {
    let reference: DatabaseReference
    let handle: UInt
    
    func remove() {
        reference.removeObserver(withHandle: handle)
    }
}

// MARK: - Public Editing Methods

extension FirebaseDatabaseChatsManager {
    func clearChat(chatIdentifier: String, userIdentifier: String) {
        databaseReference.child(Tables.usersChatsMessages)
                         .child(userIdentifier)
                         .child(chatIdentifier)
                         .removeValue()
        
        let emptyChatLatestMessage = UsersChatsLatestMessageValue(timestamp: Constants.timestampClearValue)
        
        if let latestChatLatestMessageValue = FirebaseDatabaseService.encodableToDictionary(emptyChatLatestMessage) {
            databaseReference.child(Tables.usersChatsLatestMessages)
                             .child(userIdentifier)
                             .child(chatIdentifier)
                             .setValue(latestChatLatestMessageValue)
        }
        
        let emptyUnreadMessagesCount = UsersChatsUnreadMessagesCountValue(timestamp: Constants.timestampClearValue)
        
        if let emptyUnreadMessagesCountValue = FirebaseDatabaseService.encodableToDictionary(emptyUnreadMessagesCount) {
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

extension FirebaseDatabaseChatsManager {
    func observeLoadedChats(userIdentifier: String,
                            latestUpdateTime: TimeInterval,
                            chats: [ChatInfo],
                            chatAddedCompletion: @escaping (ChatInfo) -> Void,
                            chatRemovedCompletion: @escaping (String) -> Void,
                            pairChatUpdated: @escaping (String, UserInfo) -> Void,
                            groupChatUpdated: @escaping (String, GroupInfo) -> Void,
                            chatLatestMessageUpdated: @escaping (String, MessageInfo?) -> Void,
                            chatUnreadMessagesUpdated: @escaping (String, Int) -> Void) {
        chats.forEach { chat in
            if chat.isGroup {
                
            } else {
                guard let companion = chat.companion else { return }

                fetchUserWithUpdateTime(userIdentifier: companion.identifier,
                                        latestUpdateTime: latestUpdateTime) { companion in
                    guard let companion = companion else { return }

                    pairChatUpdated(chat.identifier, companion)
                }

                fetchUserChatLatestMessageWithUpdateTime(chatIdentifier: chat.identifier,
                                                         userIdentifier: userIdentifier,
                                                         latestUpdateTime: latestUpdateTime) { latestMessage in
                    guard let latestMessage = latestMessage else { return }

                    chatLatestMessageUpdated(chat.identifier, latestMessage)
                }

                fetchChatUnreadMessagesCountWithUpdateTime(chatIdentifier: chat.identifier,
                                                           userIdentifier: userIdentifier,
                                                           latestUpdateTime: latestUpdateTime) { count in
                    guard let count = count else { return }

                    chatUnreadMessagesUpdated(chat.identifier, count)
                }
                
                observePairChat(chatIdentifier: chat.identifier,
                                userIdentifier: userIdentifier,
                                companionIdentifier: companion.identifier,
                                pairChatUpdated: pairChatUpdated,
                                chatLatestMessageUpdated: chatLatestMessageUpdated,
                                chatUnreadMessagesUpdated: chatUnreadMessagesUpdated)
            }
        }
    }
    
    func observeChats(userIdentifier: String,
                      latestUpdateTime: TimeInterval,
                      chatAddedCompletion: @escaping (ChatInfo) -> Void,
                      chatRemovedCompletion: @escaping (String) -> Void,
                      pairChatUpdated: @escaping (String, UserInfo) -> Void,
                      groupChatUpdated: @escaping (String, GroupInfo) -> Void,
                      chatLatestMessageUpdated: @escaping (String, MessageInfo?) -> Void,
                      chatUnreadMessagesUpdated: @escaping (String, Int) -> Void) {
        observeAddedChats(for: userIdentifier, latestUpdateTime: latestUpdateTime) { [weak self] chat in
            chatAddedCompletion(chat)
            
            if chat.isGroup {
                
            } else {
                guard let companion = chat.companion else { return }
                
                self?.observePairChat(chatIdentifier: chat.identifier,
                                      userIdentifier: userIdentifier,
                                      companionIdentifier: companion.identifier,
                                      pairChatUpdated: pairChatUpdated,
                                      chatLatestMessageUpdated: chatLatestMessageUpdated,
                                      chatUnreadMessagesUpdated: chatUnreadMessagesUpdated)
            }
        }
        
        observeRemovedChats(for: userIdentifier, completion: chatRemovedCompletion)
    }
}

// MARK: - Private Observe Methods

private extension FirebaseDatabaseChatsManager {
    func observePairChat(chatIdentifier: String,
                         userIdentifier: String,
                         companionIdentifier: String,
                         pairChatUpdated: @escaping (String, UserInfo) -> Void,
                         chatLatestMessageUpdated: @escaping (String, MessageInfo?) -> Void,
                         chatUnreadMessagesUpdated: @escaping (String, Int) -> Void) {
        let companionHandle = observeCompanionChanged(companionIdentifier: companionIdentifier) { companion in
            pairChatUpdated(chatIdentifier, companion)
        }
        
        let latestMessageHandle = observeLatestMessagesChanged(chatIdentifier: chatIdentifier,
                                                               userIdentifier: userIdentifier) { message in
            chatLatestMessageUpdated(chatIdentifier, message)
        }
        
        let unreadMessagesHandle = observeUnreadMessagesChanged(chatIdentifier: chatIdentifier,
                                                                userIdentifier: userIdentifier) { count in
            chatUnreadMessagesUpdated(chatIdentifier, count)
        }
        
        observedChatsData[chatIdentifier] = [companionHandle, latestMessageHandle, unreadMessagesHandle]
    }
    
    func observeRemovedChats(for userIdentifier: String, completion: @escaping (String) -> Void) {
        databaseReference.child(Tables.usersChats)
                         .child(userIdentifier)
                         .observe(.childRemoved) { snapshot in
            completion(snapshot.key)
        }
    }
    
    func observeCompanionChanged(companionIdentifier: String,
                                 completion: @escaping (UserInfo) -> Void) -> ObserverData {
        let companionReference = databaseReference.child(Tables.users).child(companionIdentifier)
        let companionHandle = companionReference.observe(.childChanged) { snapshot in
            guard let value = snapshot.value as? [String: Any],
                  let userValue = FirebaseDatabaseService.dictionaryToDecodable([snapshot.key: value],
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
                  let latestMessageValue = FirebaseDatabaseService.dictionaryToDecodable(
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
                  let latestMessageValue = FirebaseDatabaseService.dictionaryToDecodable(
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

private extension FirebaseDatabaseChatsManager {
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
                  let userValue = FirebaseDatabaseService.dictionaryToDecodable(value, type: UsersValue.self) else {
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
                  let userValue = FirebaseDatabaseService.dictionaryToDecodable(value, type: UsersValue.self) else {
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
                  let userChatLatestMessageValue = FirebaseDatabaseService.dictionaryToDecodable(
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
                  let messageValue = FirebaseDatabaseService.dictionaryToDecodable(
                    value,
                    type: ChatsMessagesValue.self
                  ) else {
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
                  let latestMessageValue = FirebaseDatabaseService.dictionaryToDecodable(
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
                  let unreadMessage = FirebaseDatabaseService.dictionaryToDecodable(
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
                  let unreadMessage = FirebaseDatabaseService.dictionaryToDecodable(
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
