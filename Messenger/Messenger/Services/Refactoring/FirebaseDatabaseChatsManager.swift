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
    
    private let databaseReference = Database.database().reference()
    private var chatsObserversInfo = ChatsObserversInfo()
}

fileprivate struct ChatsObserversInfo {
    var addedChatsHandler: UInt?
    var chatsDataHandlers = [String: [UInt]]()
}

// MARK: - Public Observe Methods

extension FirebaseDatabaseChatsManager {
    func observeLoadedChats(userIdentifier: String,
                            chats: [ChatInfo],
                            chatAddedCompletion: @escaping (ChatInfo) -> Void,
                            chatRemovedCompletion: @escaping (String) -> Void,
                            pairChatUpdated: @escaping (String, UserInfo) -> Void,
                            groupChatUpdated: @escaping (String, GroupInfo) -> Void,
                            chatLatestMessageUpdated: @escaping (String, LatestMessageInfo) -> Void,
                            chatUnreadMessagesUpdated: @escaping (String, Int) -> Void) {
        chats.forEach { chat in
            if chat.isGroup {
                
            } else {
                guard let companion = chat.companion else { return }
                
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
                      chatLatestMessageUpdated: @escaping (String, LatestMessageInfo) -> Void,
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
                         chatLatestMessageUpdated: @escaping (String, LatestMessageInfo) -> Void,
                         chatUnreadMessagesUpdated: @escaping (String, Int) -> Void) {
        observeCompanionChanged(companionIdentifier: companionIdentifier) { companion in
            pairChatUpdated(chatIdentifier, companion)
        }
        
        observeLatestMessagesChanged(chatIdentifier: chatIdentifier, userIdentifier: userIdentifier) { message in
            chatLatestMessageUpdated(chatIdentifier, message)
        }
        
        observeUnreadMessagesChanged(chatIdentifier: chatIdentifier, userIdentifier: userIdentifier) { count in
            chatUnreadMessagesUpdated(chatIdentifier, count)
        }
    }
    
    func observeAddedChats(for userIdentifier: String,
                           latestUpdateTime: TimeInterval,
                           completion: @escaping (ChatInfo) -> Void) {
        if let addedChatsHandler = chatsObserversInfo.addedChatsHandler {
            databaseReference.removeObserver(withHandle: addedChatsHandler)
        }
        
        let observerHandler = databaseReference.child(Tables.usersChats)
                                               .child(userIdentifier)
                                               .queryOrdered(byChild: "timestamp")
                                               .queryStarting(atValue: latestUpdateTime)
                                               .observe(.childAdded) { [weak self] snapshot in
            let chatIdentifier = snapshot.key

            self?.fetchGroupChatStatus(chatIdentifier: chatIdentifier) { isGroup in
                guard let isGroup = isGroup else {
                    return
                }
                
                if isGroup {
                    
                } else {
                    self?.fetchPairChat(chatIdentifier: chatIdentifier,
                                        userIdentifier: userIdentifier) { chat, error in
                        guard let chat = chat, error == nil else {
                            if let error = error {
                                switch error {
                                case .chatCompanionNotFound: print("chatCompanionNotFound")
                                case .userNotFound:          print("userNotFound")
                                case .latestMessageNotFound: print("latestMessageNotFound")
                                }
                            }
                            
                            return
                        }
                        
                        completion(chat)
                    }
                }
            }
        }
        
        chatsObserversInfo.addedChatsHandler = observerHandler
    }
    
    func observeRemovedChats(for userIdentifier: String, completion: @escaping (String) -> Void) {
        databaseReference.child(Tables.usersChats)
                         .child(userIdentifier)
                         .observe(.childRemoved) { snapshot in
            completion(snapshot.key)
        }
    }
    
    func observeLoadedCompanionChanged(companionIdentifier: String,
                                       latestUpdateTime: String,
                                       completion: @escaping (UserInfo) -> Void) {
        databaseReference.child(Tables.users)
                         .child(companionIdentifier)
//            .observe(.childChanged) {
//                
//            }
    }
    
    func observeCompanionChanged(companionIdentifier: String, completion: @escaping (UserInfo) -> Void) {
        databaseReference.child(Tables.users)
                         .child(companionIdentifier)
                         .observe(.childChanged) { snapshot in
            guard let value = snapshot.value as? [String: Any] else { return }

            let userValue = FirebaseDatabaseService.dictionaryToDecodable([snapshot.key: value], type: UsersValue.self)
            let userInfo = UserInfo(identifier: companionIdentifier,
                                    firstName: userValue.firstName,
                                    lastName: userValue.lastName,
                                    email: userValue.email,
                                    profileImageData: nil)

            completion(userInfo)
        }
    }
    
    func observeLatestMessagesChanged(chatIdentifier: String,
                                      userIdentifier: String,
                                      completion: @escaping (LatestMessageInfo) -> Void) {
        databaseReference.child(Tables.usersChatsLatestMessages)
                         .child(userIdentifier)
                         .child(chatIdentifier)
                         .observe(.childChanged) { [weak self] snapshot in
            guard let value = snapshot.value as? [String: Any] else { return }
                
            let chatIdentifier = snapshot.key
            let latestMessageValue = FirebaseDatabaseService.dictionaryToDecodable(
                value,
                type: UsersChatsLatestMessageValue.self
            )

            self?.fetchChatMessage(chatIdentifier: chatIdentifier,
                                   messageIdentifier: latestMessageValue.identifier) { message in
                guard let message = message else { return }
                
                completion(message)
            }
        }
    }
    
    func observeUnreadMessagesChanged(chatIdentifier: String,
                                      userIdentifier: String,
                                      completion: @escaping (Int) -> Void) {
        databaseReference.child(Tables.usersChatsUnread)
                         .child(userIdentifier)
                         .child(chatIdentifier)
                         .observe(.childChanged) { snapshot in
            guard let count = snapshot.value as? Int else { return }
                            
            completion(count)
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
                    guard let latestMessage = latestMessage else {
                        completion(nil, .latestMessageNotFound)
                        
                        return
                    }
                    
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
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil)

                return
            }
                            
            let userValue = FirebaseDatabaseService.dictionaryToDecodable(value, type: UsersValue.self)
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
                                    completion: @escaping (LatestMessageInfo?) -> Void) {
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
    
    func fetchChatMessage(chatIdentifier: String,
                          messageIdentifier: String,
                          completion: @escaping (LatestMessageInfo?) -> Void) {
        databaseReference.child(Tables.chatsMessages)
                               .child(chatIdentifier)
                               .child(messageIdentifier)
                               .observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil)
                
                return
            }
    
            let messageValue = FirebaseDatabaseService.dictionaryToDecodable(value, type: ChatsMessagesValue.self)
            let message = LatestMessageInfo(senderIdentifier: messageValue.senderIdentifier,
                                            type: messageValue.messageType,
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
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil)
                
                return
            }
                            
            let latestMessageValue = FirebaseDatabaseService.dictionaryToDecodable(
                value,
                type: UsersChatsLatestMessageValue.self
            )
                            
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
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil)

                return
            }
                            
            let unreadMessage = FirebaseDatabaseService.dictionaryToDecodable(
                value,
                type: UsersChatsUnreadMessagesCountValue.self
            )

            completion(unreadMessage.count)
        }
    }
}
