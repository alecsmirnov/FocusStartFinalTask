//
//  FirebaseDatabaseService.swift
//  Messenger
//
//  Created by Admin on 24.11.2020.
//

import FirebaseDatabase

enum FirebaseDatabaseStructure {
    typealias UserIdentifier    = String
    typealias ChatIdentifier    = String
    typealias MessageIdentifier = String
    
    typealias Users         = [UserIdentifier: UsersValue]
    typealias UsersChats    = [UserIdentifier: [ChatIdentifier: UsersChatsValue]]
    typealias Chats         = [ChatIdentifier: MessageIdentifier]
    typealias ChatsMessages = [ChatIdentifier: ChatsMessagesValue]
}

enum FirebaseDatabaseService {
    // MARK: Completions
    
    typealias FetchUsersCompletion = (FirebaseDatabaseStructure.Users?) -> Void
    typealias UserExistCompletion = (Bool) -> Void
    
    typealias SendMessageCompletion = (SendError?) -> Void
    typealias FetchChatsCompletion = ([FirebaseChat]?, FetchError?) -> Void
    typealias FetchChatCompletion = (FirebaseChat?, FetchError?) -> Void
    typealias FetchMessageCompletion = (FirebaseDatabaseStructure.ChatsMessages?) -> Void
    
    // MARK: Properties
    
    enum SearchKey: String {
        case name = "queryable_name"
        case userName = "queryable_user_name"
        case email
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
        static let anyCharacter = "\u{f8ff}"
    }
    
    private enum Tables {
        static let users = "users"
        static let chats = "chats"
        static let chatsMessages = "chats_messages"
        static let usersChats = "users_chats"
        
        enum Chats {
            static let updateTimestamp = "update_timestamp"
        }
        
        enum ChatsMessages {
            static let creationTimestamp = "creation_timestamp"
        }
    }
    
    static private let databaseReference = Database.database().reference()
}

// MARK: - Methods For Work With Users

extension FirebaseDatabaseService {
    static func addUser(_ user: UsersValue, identifier: String) {
        if let userRecord = encodableToDictionary(user) {
            databaseReference.child(Tables.users).child(identifier).setValue(userRecord)
        }
    }
    
    static func fetchUsers(by parameter: String, key: SearchKey, completion: @escaping FetchUsersCompletion) {
        let queryableParameter = parameter.lowercased()
        
        databaseReference.child(Tables.users)
                         .queryOrdered(byChild: key.rawValue)
                         .queryStarting(atValue: queryableParameter)
                         .queryEnding(atValue: queryableParameter + Constants.anyCharacter)
                         .observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil)
                
                return
            }
                            
            completion(dictionaryToDecodable(value, type: [String: UsersValue].self))
        }
    }
    
    static func isUserExist(withEmail email: String, completion: @escaping UserExistCompletion) {
        fetchUsers(by: email, key: .email) { users in
            guard let isEmpty = users?.isEmpty, !isEmpty else {
                completion(false)
                
                return
            }
            
            completion(true)
        }
    }
}

// MARK: - Methods For Work With Chats

extension FirebaseDatabaseService {
    static func send(message: ChatsMessagesValue, to userIdentifier: String, completion: @escaping SendMessageCompletion) {
        databaseReference.child(Tables.users).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.hasChild(message.senderIdentifier) else {
                completion(.senderNotFound)
                
                return
            }
            
            databaseReference.child(Tables.users).observeSingleEvent(of: .value) { snapshot in
                guard snapshot.hasChild(userIdentifier) else {
                    completion(.receiverNotFound)
                    
                    return
                }
                
                databaseReference.child(Tables.usersChats)
                                 .child(message.senderIdentifier)
                                 .observeSingleEvent(of: .value) { snapshot in
                    let chatIdentifier = getChatIdentifier(userIdentifier1: message.senderIdentifier,
                                                           userIdentifier2: userIdentifier)
                                    
                    if !snapshot.hasChild(chatIdentifier) {
                        let userRecord = encodableToDictionary(UsersChatsValue(userIdentifier: userIdentifier))
                        let senderRecord = encodableToDictionary(
                            UsersChatsValue(userIdentifier: message.senderIdentifier)
                        )
                        
                        databaseReference.child(Tables.usersChats)
                                         .child(message.senderIdentifier)
                                         .child(chatIdentifier)
                                         .setValue(userRecord)
                        
                        databaseReference.child(Tables.usersChats)
                                         .child(userIdentifier)
                                         .child(chatIdentifier)
                                         .setValue(senderRecord)
                    }
                                    
                    add(message: message, to: chatIdentifier)
                }
            }
        }
    }
    
    static func fetchChats(for identifier: String, completion: @escaping FetchChatsCompletion) {
        databaseReference.child(Tables.usersChats).child(identifier).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil, .chatNotFound)
                
                return
            }

            let dispatchGroup = DispatchGroup()
            var chats = [FirebaseChat]()
            
            let userChats = dictionaryToDecodable(value, type: [String: UsersChatsValue].self)
            
            userChats.forEach { chatIdentifier, chat in
                dispatchGroup.enter()
                
                databaseReference.child(Tables.users)
                                 .child(chat.userIdentifier)
                                 .observeSingleEvent(of: .value) { snapshot in
                    guard let value = snapshot.value as? [String: Any] else {
                        completion(nil, .userNotFound)
                        
                        return
                    }
                                    
                    let user = dictionaryToDecodable(value, type: UsersValue.self)
                    
                    databaseReference.child(Tables.chats)
                                     .child(chatIdentifier)
                                     .observeSingleEvent(of: .value) { snapshot in
                        guard let latestMessageIdentifier = snapshot.value as? String else {
                            completion(nil, .latestMessageNotFound)
                            
                            return
                        }
                                        
                        databaseReference.child(Tables.chatsMessages)
                                         .child(chatIdentifier)
                                         .child(latestMessageIdentifier)
                                         .observeSingleEvent(of: .value) { snapshot in
                            guard let value = snapshot.value as? [String: Any] else {
                                completion(nil, .messageNotFound)
                                
                                return
                            }
                                            
                            let latestMessage = dictionaryToDecodable(value, type: ChatsMessagesValue.self)
                            let chat = FirebaseChat(chatIdentifier: chatIdentifier,
                                                    userIdentifier: chat.userIdentifier,
                                                    user: user,
                                                    latestMessage: latestMessage)
                                            
                            chats.append(chat)
                                            
                            dispatchGroup.leave()
                        }
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(chats, nil)
            }
        }
    }
    
    static func observeAddedChats(for identifier: String, completion: @escaping FetchChatCompletion) {
        let currentTimestamp = Date().timeIntervalSince1970

        databaseReference.child(Tables.usersChats)
                         .child(identifier)
                         .queryOrdered(byChild: Tables.ChatsMessages.creationTimestamp)
                         .queryStarting(atValue: currentTimestamp)
                         .observe(.childAdded) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil, .chatNotFound)
                
                return
            }
            
            let chatIdentifier = snapshot.key
            let userIdentifier = dictionaryToDecodable(value, type: UsersChatsValue.self).userIdentifier
            
            databaseReference.child(Tables.users)
                             .child(userIdentifier)
                             .observeSingleEvent(of: .value) { snapshot in
                guard let value = snapshot.value as? [String: Any] else {
                    completion(nil, .userNotFound)
                    
                    return
                }
                                
                let user = dictionaryToDecodable(value, type: UsersValue.self)
                
                databaseReference.child(Tables.chats)
                                 .child(chatIdentifier)
                                 .observeSingleEvent(of: .value) { snapshot in
                    guard let latestMessageIdentifier = snapshot.value as? String else {
                        completion(nil, .latestMessageNotFound)
                        
                        return
                    }
                                    
                    databaseReference.child(Tables.chatsMessages)
                                     .child(chatIdentifier)
                                     .child(latestMessageIdentifier)
                                     .observeSingleEvent(of: .value) { snapshot in
                        guard let value = snapshot.value as? [String: Any] else {
                            completion(nil, .messageNotFound)
                            
                            return
                        }
                                        
                        let latestMessage = dictionaryToDecodable(value, type: ChatsMessagesValue.self)
                        let chat = FirebaseChat(chatIdentifier: chatIdentifier,
                                                userIdentifier: userIdentifier,
                                                user: user,
                                                latestMessage: latestMessage)
                                        
                        completion(chat, nil)
                    }
                }
            }
        }
    }
    
    static func observeRemovedChats(for identifier: String, completion: @escaping (String) -> Void) {
        databaseReference.child(Tables.usersChats).child(identifier).observe(.childRemoved) { snapshot in
            completion(snapshot.key)
        }
    }
    
    static func observeChatsLatestMessagesChanged(for identifier: String,
                                                  completion: @escaping FetchMessageCompletion) {
        databaseReference.child(Tables.usersChats).child(identifier).observeSingleEvent(of: .value) { snapshot in
            guard let userChats = snapshot.value as? [String: Any] else {
                completion(nil)
                
                return
            }
            
            userChats.forEach { chatIdentifier, _ in
                databaseReference.child(Tables.chats)
                                 .child(chatIdentifier)
                                 .observe(.value) { snapshot in
                    guard let latestMessageIdentifier = snapshot.value as? String else { return }
                    
                    databaseReference.child(Tables.chatsMessages)
                                     .child(chatIdentifier)
                                     .child(latestMessageIdentifier)
                                     .observeSingleEvent(of: .value) { snapshot in
                        guard let value = snapshot.value as? [String: Any] else {
                            completion(nil)
                            
                            return
                        }
                                        
                        let latestMessage = dictionaryToDecodable(value, type: ChatsMessagesValue.self)
                                        
                        completion([chatIdentifier: latestMessage])
                    }
                }
            }
        }
    }
    
    static func observeUsersChanged(for identifier: String, completion: @escaping FetchUsersCompletion) {
//        databaseReference.child(Tables.users).observe(.childChanged) { snapshot in
//            guard let usersRecord = snapshot.value as? [String: Any] else { return }
//
//            databaseReference.child(Tables.usersChats).child(identifier).observeSingleEvent(of: .value) { snapshot in
//                guard let userChatsRecord = snapshot.value as? [String: Any] else {
//                    completion(nil)
//
//                    return
//                }
//
//                let userChats = dictionaryToDecodable(userChatsRecord, type: [String: UsersChatsValue].self)
//
//                usersRecord.forEach { userIdentifier, _ in
//                    if userChats.values.contains(where: { $0.userIdentifier == userIdentifier }) {
//                        databaseReference.child(Tables.users).child(userIdentifier).observe(.value) { snapshot in
//                            guard let value = snapshot.value as? [String: Any] else {
//                                completion(nil)
//
//                                return
//                            }
//
//                            let firebaseUser = dictionaryToDecodable(value, type: UsersValue.self)
//
//                            completion([userIdentifier: firebaseUser])
//                        }
//                    }
//                }
//            }
        
        
        databaseReference.child(Tables.usersChats).child(identifier).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil)

                return
            }

            let userChats = dictionaryToDecodable(value, type: [String: UsersChatsValue].self)

            userChats.forEach { chatIdentifier, userChat in
                databaseReference.child(Tables.users).child(userChat.userIdentifier).observe(.value) { snapshot in
                    guard let value = snapshot.value as? [String: Any] else {
                        completion(nil)

                        return
                    }

                    let firebaseUser = dictionaryToDecodable(value, type: UsersValue.self)

                    completion([userChat.userIdentifier: firebaseUser])
                }
            }
        }
    }
}

private extension FirebaseDatabaseService {
    static func add(message: ChatsMessagesValue, to chatIdentifier: String) {
        guard let messageIdentifier = databaseReference.child(Tables.chatsMessages)
                                                       .child(chatIdentifier)
                                                       .childByAutoId().key else { return }
        databaseReference.child(Tables.chatsMessages)
                         .child(chatIdentifier)
                         .child(messageIdentifier)
                         .setValue(encodableToDictionary(message))
        
        databaseReference.child(Tables.chats)
                         .child(chatIdentifier)
                         .setValue(messageIdentifier)
    }
}

// MARK: - Get Methods

extension FirebaseDatabaseService {
}

// MARK: - Search Methods

extension FirebaseDatabaseService {

}

// MARK: - Helper Methods

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
    
    static func dictionaryToArray<T>(_ dictionary: [String: T]) -> [T] {
        return Array(dictionary.values.map { $0 })
    }
    
    static func getChatIdentifier(userIdentifier1: String, userIdentifier2: String) -> String {
        let chatIdentifier = (userIdentifier1 < userIdentifier2) ? userIdentifier1 + userIdentifier2 :
                                                                   userIdentifier2 + userIdentifier1
        return chatIdentifier
    }
}
