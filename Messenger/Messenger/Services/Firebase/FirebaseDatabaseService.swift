//
//  FirebaseDatabaseService.swift
//  Messenger
//
//  Created by Admin on 24.11.2020.
//

import FirebaseDatabase

enum Tables {
    static let users = "users"
    
    static let chatsMessages = "chats_messages"
    static let chatsMembers = "chats_members"
    static let chatsInfo = "chats_info"
    static let chatsInfoGroup = "chats_info_group"
    
    static let usersChats = "users_chats"
    static let usersChatsMessages = "users_chats_messages"
    static let usersChatsLatestMessages = "users_chats_latest_messages"
    static let usersChatsUnread = "users_chats_unread_messages_count"
}

enum FirebaseDatabaseService {
    // MARK: Completions
    
    typealias FetchUsersCompletion = ([String: UsersValue]?) -> Void
    typealias UserExistCompletion = (Bool) -> Void
    
    typealias SendMessageCompletion = (SendError?) -> Void
    typealias FetchChatsCompletion = ([FirebaseChat]?, FetchError?) -> Void
    typealias FetchChatCompletion = (FirebaseChat?, FetchError?) -> Void
    typealias FetchMessageCompletion = ([String: ChatsMessagesValue]?) -> Void
    
    // MARK: Properties
    
    enum SearchKey: String {
        case name = "info/queryable_name"
        case userName = "info/queryable_user_name"
        case email = "info/email"
    }
    
    enum SendError: Error {
        case senderNotFound
        case receiverNotFound
        case chatNotFound
    }
    
    enum FetchError: Error {
        case chatNotFound
        case userNotFound
        case messageNotFound
        case latestMessageNotFound
    }
    
    private enum Constants {
        static var currentTimestamp: TimeInterval {
            return Date().timeIntervalSince1970
        }
        
        // to delete chat from observation
        static let userActiveValue = true
        
        static let emptyValue = 0
        static let counterInitialValue = 1
        
        static let anyCharacterValue = "\u{f8ff}"
    }
    

    
    private static let databaseReference = Database.database().reference()
}

// MARK: - Users

extension FirebaseDatabaseService {
    static func addUser(_ user: UsersValue, identifier: String) {
        if let userRecord = encodableToDictionary(user) {
            databaseReference.child(Tables.users)
                             .child(identifier)
                             .setValue(userRecord)
        }
    }
}

// MARK: - Fetch Users

extension FirebaseDatabaseService {
    static func fetchUsers(completion: @escaping FetchUsersCompletion) {
        databaseReference.child(Tables.users)
                         .observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil)
                
                return
            }
                            
            completion(dictionaryToDecodable(value, type: [String: UsersValue].self))
        }
    }
    
    static func fetchUsers(by parameter: String, key: SearchKey, completion: @escaping FetchUsersCompletion) {
        let queryableParameter = parameter.lowercased()
        
        databaseReference.child(Tables.users)
                         .queryOrdered(byChild: key.rawValue)
                         .queryStarting(atValue: queryableParameter)
                         .queryEnding(atValue: queryableParameter + Constants.anyCharacterValue)
                         .observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil)
                
                return
            }
                            
            completion(dictionaryToDecodable(value, type: [String: UsersValue].self))
        }
    }
    
    static func fetchUser(userIdentifier: String, completion: @escaping (UsersValue?) -> Void) {
        databaseReference.child(Tables.users)
                         .child(userIdentifier)
                         .observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil)

                return
            }
                            
            let user = dictionaryToDecodable(value, type: UsersValue.self)
                            
            completion(user)
        }
    }
    
    static func fetchUserChatsIdentifiers(userIdentifier: String, completion: @escaping ([String]?) -> Void) {
        databaseReference.child(Tables.usersChats)
                         .child(userIdentifier)
                         .observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil)
                
                return
            }

            let userChatsIdentifiers = value.map { $0.key }
                            
            completion(userChatsIdentifiers)
        }
    }
}

// MARK: - Observe User

extension FirebaseDatabaseService {
    static func observeUserCompanionsChanged(userIdentifier: String, completion: @escaping FetchUsersCompletion) {
        databaseReference.child(Tables.usersChats)
                         .child(userIdentifier)
                         .observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil)

                return
            }

            value.forEach { chatIdentifier, _ in
                fetchChatCompanionIdentifier(userIdentifier: userIdentifier,
                                             chatIdentifier: chatIdentifier) { companionIdentifier in
                    guard let companionIdentifier = companionIdentifier else {
                        completion(nil)
                        
                        return
                    }
                    
                    observeUserChanged(userIdentifier: companionIdentifier, completion: completion)
                }
            }
        }
    }
    
    static func observeUserChanged(userIdentifier: String, completion: @escaping FetchUsersCompletion) {
        databaseReference.child(Tables.users)
                         .child(userIdentifier)
                         .observe(.childChanged) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil)

                return
            }

            let firebaseUser = dictionaryToDecodable([snapshot.key: value], type: UsersValue.self)

            completion([userIdentifier: firebaseUser])
        }
    }
}

// MARK: - Chats

extension FirebaseDatabaseService {
    static func createChatBetween(userIdentifier1: String, userIdentifier2: String) -> String? {
        guard let chatIdentifier = createChat(withMember: userIdentifier1) else { return nil }
        
        addChatMember(userIdentifier: userIdentifier2, chatIdentifier: chatIdentifier)
        
        return chatIdentifier
    }
}

private extension FirebaseDatabaseService {
    static func addChatMember(userIdentifier: String, chatIdentifier: String) {
        databaseReference.child(Tables.chatsMembers)
                         .child(chatIdentifier)
                         .child(userIdentifier)
                         .setValue(Constants.userActiveValue)

        databaseReference.child(Tables.usersChats)
                         .child(userIdentifier)
                         .child(chatIdentifier)
                         .child("timestamp")
                         .setValue(Constants.currentTimestamp)
    }
    
    static func createPairChatBetween(user userIdentifier1: String, andUser userIdentifier2: String) -> String {
        let chatIdentifier = getPairChatIdentifier(userIdentifier1: userIdentifier1, userIdentifier2: userIdentifier2)
        
        addChatMember(userIdentifier: userIdentifier1, chatIdentifier: chatIdentifier)
        addChatMember(userIdentifier: userIdentifier2, chatIdentifier: chatIdentifier)
        
        return chatIdentifier
    }
    
    static func getPairChatIdentifier(userIdentifier1: String, userIdentifier2: String) -> String {
        let chatIdentifier = (userIdentifier1 < userIdentifier2) ? userIdentifier1 + userIdentifier2 :
                                                                   userIdentifier2 + userIdentifier1
        return chatIdentifier
    }
    
    // MARK: Group
    
    static func createGroupChat(creatorIdentifier: String, name: String) -> String {
        
        
        return ""
    }
    
    static func createChat(withMember userIdentifier: String) -> String? {
        guard let chatIdentifier = databaseReference.child(Tables.chatsMessages).childByAutoId().key else {
            return nil
        }
        
        addChatMember(userIdentifier: userIdentifier, chatIdentifier: chatIdentifier)
        
        return chatIdentifier
    }
}

// MARK: - Fetch Chats

extension FirebaseDatabaseService {
    static func fetchChats(for userIdentifier: String, completion: @escaping FetchChatsCompletion) {
        fetchUserChatsIdentifiers(userIdentifier: userIdentifier) { chatsIdentifiers in
            guard let chatsIdentifiers = chatsIdentifiers else {
                completion(nil, .chatNotFound)
                
                return
            }

            let dispatchGroup = DispatchGroup()
            var chats = [FirebaseChat]()
            
            chatsIdentifiers.forEach { chatIdentifier in
                dispatchGroup.enter()
                
                fetchChat(userIdentifier: userIdentifier, chatIdentifier: chatIdentifier) { chat, error in
                    guard let chat = chat, error == nil else {
                        completion(nil, error)
                        
                        return
                    }
                    
                    chats.append(chat)

                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(chats, nil)
            }
        }
    }
}

private extension FirebaseDatabaseService {
    static func fetchChat(userIdentifier: String,
                          chatIdentifier: String,
                          completion: @escaping (FirebaseChat?, FetchError?) -> Void) {
        fetchChatCompanionIdentifier(userIdentifier: userIdentifier,
                                     chatIdentifier: chatIdentifier) { companionIdentifier in
            guard let companionIdentifier = companionIdentifier else { return }
            
            fetchUser(userIdentifier: companionIdentifier) { companion in
                guard let companion = companion else {
                    completion(nil, .userNotFound)
                    
                    return
                }
                                
                fetchChatLatestMessageIdentifier(userIdentifier: userIdentifier,
                                                 chatIdentifier: chatIdentifier) { latestMessageIdentifier in
                    guard let latestMessageIdentifier = latestMessageIdentifier else {
                        completion(nil, .latestMessageNotFound)
                        
                        return
                    }
                    
                    fetchChatMessage(chatIdentifier: chatIdentifier,
                                     messageIdentifier: latestMessageIdentifier) { chatMessage in
                        guard let chatMessage = chatMessage else {
                            completion(nil, .messageNotFound)
                            
                            return
                        }
                        
                        fetchChatUnreadMessagesCount(userIdentifier: userIdentifier,
                                                     chatIdentifier: chatIdentifier) { count in
                            var unreadMessagesCount = 0
                            
                            if let count = count {
                                unreadMessagesCount = count
                            }
                            
                            let chat = FirebaseChat(chatIdentifier: chatIdentifier,
                                                    userIdentifier: companionIdentifier,
                                                    user: companion,
                                                    latestMessage: chatMessage,
                                                    unreadMessagesCount: unreadMessagesCount)
                            
                            completion(chat, nil)
                        }
                    }
                }
            }
        }
    }
    
    static func fetchChatMessage(chatIdentifier: String,
                                 messageIdentifier: String,
                                 completion: @escaping (ChatsMessagesValue?) -> Void) {
        databaseReference.child(Tables.chatsMessages)
                         .child(chatIdentifier)
                         .child(messageIdentifier)
                         .observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil)

                return
            }
    
            let message = dictionaryToDecodable(value, type: ChatsMessagesValue.self)
                            
            completion(message)
        }
    }
    
    static func fetchChatLatestMessageIdentifier(userIdentifier: String,
                                                 chatIdentifier: String,
                                                 completion: @escaping (String?) -> Void) {
        databaseReference.child(Tables.usersChatsLatestMessages)
                         .child(userIdentifier)
                         .child(chatIdentifier)
                         .observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil)
                
                return
            }
                            
            let latestMessage = dictionaryToDecodable(value, type: UsersChatsLatestMessageValue.self)
                            
            completion(latestMessage.identifier)
        }
    }
    
    static func fetchChatCompanionIdentifier(userIdentifier: String,
                                             chatIdentifier: String,
                                             completion: @escaping (String?) -> Void) {
        fetchChatMembersIdentifiers(chatIdentifier: chatIdentifier) { membersIdentifiers in
            guard let memberIdentifier = membersIdentifiers?.filter({ $0 != userIdentifier }).first else {
                completion(nil)
                
                return
            }
            
            completion(memberIdentifier)
        }
    }
    
    static func fetchChatMembersIdentifiers(chatIdentifier: String, completion: @escaping ([String]?) -> Void) {
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
    
    static func fetchChatUnreadMessagesCount(userIdentifier: String,
                                             chatIdentifier: String,
                                             completion: @escaping (Int?) -> Void) {
        databaseReference.child(Tables.usersChatsUnread)
                         .child(userIdentifier)
                         .child(chatIdentifier)
            //.child("count")
                         .observeSingleEvent(of: .value) { snapshot in
            guard let count = snapshot.value as? Int else {
                completion(nil)

                return
            }

            completion(count)
        }
    }
}

// MARK: - Observe Chats

extension FirebaseDatabaseService {
    static func observeAddedChats(for userIdentifier: String, completion: @escaping FetchChatCompletion) {
        databaseReference.child(Tables.usersChats)
                         .child(userIdentifier)
                         .queryOrdered(byChild: "timestamp")
                         .queryStarting(atValue: Constants.currentTimestamp)
                         .observe(.childAdded) { snapshot in
            let chatIdentifier = snapshot.key
                            
            fetchChat(userIdentifier: userIdentifier, chatIdentifier: chatIdentifier) { chat, error in
                guard let chat = chat, error == nil else {
                    completion(nil, error)
                    
                    return
                }
                
                completion(chat, nil)
            }
        }
    }
    
    static func observeRemovedChats(for identifier: String, completion: @escaping (String) -> Void) {
        databaseReference.child(Tables.usersChats)
                         .child(identifier)
                         .observe(.childRemoved) { snapshot in
            completion(snapshot.key)
        }
    }
    
    static func observeChatsLatestMessagesChanged(for userIdentifier: String,
                                                  completion: @escaping FetchMessageCompletion) {
        databaseReference.child(Tables.usersChatsLatestMessages)
                         .child(userIdentifier)
                         .observe(.childChanged) { snapshot in
            guard let value = snapshot.value as? [String: Any] else { return }
                
            let chatIdentifier = snapshot.key
            let latestMessage = dictionaryToDecodable(value, type: UsersChatsLatestMessageValue.self)

            fetchChatMessage(chatIdentifier: chatIdentifier,
                             messageIdentifier: latestMessage.identifier) { message in
                guard let message = message else {
                    completion(nil)

                    return
                }

                completion([chatIdentifier: message])
            }
        }
    }
    
    static func observeChatUnreadMessagesCountChanged(userIdentifier: String,
                                                      chatIdentifier: String,
                                                      completion: @escaping (Int?) -> Void) {
        databaseReference.child(Tables.usersChatsUnread)
                         .child(userIdentifier)
                         .child(chatIdentifier)
                         .observe(.childChanged) { snapshot in
            guard let count = snapshot.value as? Int else {
                completion(nil)

                return
            }

            completion(count)
        }
    }
}

// MARK: - Messages

extension FirebaseDatabaseService {
    static func sendMessage(_ message: ChatsMessagesValue, chatIdentifier: String) {
        fetchChatMembersIdentifiers(chatIdentifier: chatIdentifier) { membersIdentifiers in
            guard let membersIdentifiers = membersIdentifiers,
                  let messageIdentifier = databaseReference.child(Tables.chatsMessages)
                                                           .child(chatIdentifier)
                                                           .childByAutoId().key else {
                // TODO: unable to send error
                return
            }
            
            databaseReference.child(Tables.chatsMessages)
                             .child(chatIdentifier)
                             .child(messageIdentifier)
                             .setValue(encodableToDictionary(message))
            
            membersIdentifiers.forEach { memberIdentifier in
                databaseReference.child(Tables.usersChatsMessages)
                                 .child(memberIdentifier)
                                 .child(chatIdentifier)
                                 .child(messageIdentifier)
                                 .setValue(Constants.emptyValue)
                
                let latestMessage = UsersChatsLatestMessageValue(identifier: messageIdentifier,
                                                                 timestamp: message.timestamp)
                
                databaseReference.child(Tables.usersChatsLatestMessages)
                    .child(memberIdentifier)
                    .child(chatIdentifier)
                    .setValue(encodableToDictionary(latestMessage))
                    
                if message.senderIdentifier != memberIdentifier {
                    increaseUnreadMessagesCount(userIdentifier: memberIdentifier, chatIdentifier: chatIdentifier)
                }
            }
        }
    }
    
    static func markMessageAsRead(chatIdentifier: String, userIdentifier: String, messageIdentifier: String) {
        databaseReference.child(Tables.chatsMessages)
                         .child(chatIdentifier)
                         .child(messageIdentifier)
                         .child("is_read")
                         .setValue(true)
        
        decreaseUnreadMessagesCount(userIdentifier: userIdentifier, chatIdentifier: chatIdentifier)
    }
}

private extension FirebaseDatabaseService {
    static func increaseUnreadMessagesCount(userIdentifier: String, chatIdentifier: String) {
        let counterReference = databaseReference.child(Tables.usersChatsUnread)
                                                .child(userIdentifier)
                                                .child(chatIdentifier)
            //.child("count")
        // TODO: access to UsersChatsUnreadMessagesCountValue
        
        counterReference.runTransactionBlock { mutableDat in
            if let value = mutableDat.value as? Int {
                mutableDat.value = value + 1
            } else {
                mutableDat.value = Constants.counterInitialValue
            }
            
            return TransactionResult.success(withValue: mutableDat)
        }
    }
    
    static func decreaseUnreadMessagesCount(userIdentifier: String, chatIdentifier: String) {
        let counterReference = databaseReference.child(Tables.usersChatsUnread)
                                                .child(userIdentifier)
                                                .child(chatIdentifier)
            //.child("count")
        
        counterReference.runTransactionBlock { mutableDat in
            if let value = mutableDat.value as? Int {
                if Constants.counterInitialValue < value {
                    mutableDat.value = value - 1
                } else {
                    mutableDat.value = 0
                }
            }
            
            return TransactionResult.success(withValue: mutableDat)
        }
    }
}

// MARK: - Fetch Messages

extension FirebaseDatabaseService {
    static func observeChatMessages(userIdentifier: String,
                                    chatIdentifier: String,
                                    completion: @escaping (Message) -> Void) {
        databaseReference.child(Tables.usersChatsMessages)
                         .child(userIdentifier)
                         .child(chatIdentifier)
                         .observe(.childAdded) { snapshot in
            let messageIdentifier = snapshot.key
            
            fetchChatMessage(chatIdentifier: chatIdentifier,
                             messageIdentifier: messageIdentifier) { message in
                if let message = message {
                    completion(Message(identifier: messageIdentifier, data: message))
                }
            }
        }
    }
    
    static func observeChatMessagesChange(chatIdentifier: String,
                                          completion: @escaping (Message) -> Void) {
        databaseReference.child(Tables.chatsMessages)
                         .child(chatIdentifier)
                         .observe(.childChanged) { snapshot in
            guard let value = snapshot.value as? [String: Any] else { return }
                            
            let messageIdentifier = snapshot.key
            let message = dictionaryToDecodable(value, type: ChatsMessagesValue.self)

            completion(Message(identifier: messageIdentifier, data: message))
         }
    }
}

// MARK: - Helpers

extension FirebaseDatabaseService {
    static func encodableToDictionary<T>(_ data: T) -> [String: Any]? where T: Encodable {
        let dictionary: [String: Any]?
        
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(data)
            let dictionaryData = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
            
            dictionary = dictionaryData as? [String: Any]
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
        return dictionary
    }
    
    static func dictionaryToDecodable<T>(_ dictionary: [String: Any], type: T.Type) -> T where T: Decodable {
        let jsonType: T
        
        do {
            let jsonDecoder = JSONDecoder()
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary)
            
            jsonType = try jsonDecoder.decode(T.self, from: jsonData)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
        return jsonType
    }
}
