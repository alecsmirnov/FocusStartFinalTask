//
//  FirebaseDatabaseChatLogManager.swift
//  Messenger
//
//  Created by Admin on 14.12.2020.
//

import FirebaseDatabase

final class FirebaseDatabaseChatLogManager {
    private let databaseReference = Database.database().reference()
}

extension FirebaseDatabaseChatLogManager {
    func observeChatLogAddedMessages(chatIdentifier: String,
                                     userIdentifier: String,
                                     latestUpdateTime: TimeInterval,
                                     completion: @escaping (MessageInfo) -> Void) {
        databaseReference.child(Tables.usersChatsMessages)
                         .child(userIdentifier)
                         .child(chatIdentifier)
                         .queryOrderedByValue()
                         .queryStarting(atValue: latestUpdateTime)
                         .observe(.childAdded) { [weak self] snapshot in
            let messageIdentifier = snapshot.key
                            
            self?.fetchChatMessage(chatIdentifier: chatIdentifier,
                                   messageIdentifier: messageIdentifier) { messageValue in
                if let messageValue = messageValue {
                    let message = MessageInfo(identifier: messageIdentifier,
                                              senderIdentifier: messageValue.senderIdentifier,
                                              type: messageValue.messageType,
                                              isRead: messageValue.isRead,
                                              timestamp: messageValue.timestamp,
                                              isIncoming: messageValue.senderIdentifier != userIdentifier)
                    completion(message)
                }
            }
        }
    }
    
    func observeChatLogAddedMessagesWithLastNumber(chatIdentifier: String,
                                     userIdentifier: String,
                                     latestUpdateTime: TimeInterval,
                                     toLast limit: UInt,
                                     topMessageIdentifier: String,
                                     completion: @escaping (MessageInfo) -> Void) {
        databaseReference.child(Tables.usersChatsMessages)
                         .child(userIdentifier)
                         .child(chatIdentifier)
                         .queryOrderedByValue()
                         .queryStarting(atValue: latestUpdateTime)
            .queryEnding(atValue: topMessageIdentifier)
            .queryLimited(toLast: limit)
                         .observe(.childAdded) { [weak self] snapshot in
            let messageIdentifier = snapshot.key
                            
            self?.fetchChatMessage(chatIdentifier: chatIdentifier,
                                   messageIdentifier: messageIdentifier) { messageValue in
                if let messageValue = messageValue {
                    let message = MessageInfo(identifier: messageIdentifier,
                                              senderIdentifier: messageValue.senderIdentifier,
                                              type: messageValue.messageType,
                                              isRead: messageValue.isRead,
                                              timestamp: messageValue.timestamp)
                    completion(message)
                }
            }
        }
    }
    
    func fetchChatMessage(chatIdentifier: String,
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
                            
            let message = FirebaseDatabaseCoding.fromDictionary(value, type: ChatsMessagesValue.self)
                            
            completion(message)
        }
    }
}

// MARK: - Public Methods

extension FirebaseDatabaseChatLogManager {
    func sendMessage(_ messageType: ChatsMessagesType, chatIdentifier: String, senderIdentifier: String) {
        fetchChatMembersIdentifiers(chatIdentifier: chatIdentifier) { [weak self] membersIdentifiers in
            guard let membersIdentifiers = membersIdentifiers,
                  let messageIdentifier = self?.databaseReference.child(Tables.chatsMessages)
                                                                 .child(chatIdentifier)
                                                                 .childByAutoId().key else { return }
            
            let message = ChatsMessagesValue(senderIdentifier: senderIdentifier,
                                             messageType: messageType,
                                             timestamp: Date().timeIntervalSince1970,
                                             isRead: false)
            
            self?.databaseReference.child(Tables.chatsMessages)
                                   .child(chatIdentifier)
                                   .child(messageIdentifier)
                                   .setValue(FirebaseDatabaseCoding.toDictionary(message))
            
            membersIdentifiers.forEach { memberIdentifier in
                self?.databaseReference.child(Tables.usersChatsMessages)
                                       .child(memberIdentifier)
                                       .child(chatIdentifier)
                                       .child(messageIdentifier)
                                       .setValue(message.timestamp)
                
                let latestMessage = UsersChatsLatestMessageValue(identifier: messageIdentifier,
                                                                 timestamp: message.timestamp)
                
                self?.databaseReference.child(Tables.usersChatsLatestMessages)
                                       .child(memberIdentifier)
                                       .child(chatIdentifier)
                                       .setValue(FirebaseDatabaseCoding.toDictionary(latestMessage))
                    
                if message.senderIdentifier != memberIdentifier {
                    self?.increaseUnreadMessagesCount(userIdentifier: memberIdentifier, chatIdentifier: chatIdentifier)
                    
                    self?.databaseReference.child(Tables.usersChats)
                                           .child(memberIdentifier)
                                           .child(chatIdentifier)
                                           .observeSingleEvent(of: .value) { snapshot in
                        if !snapshot.exists() {
                            self?.databaseReference.child(Tables.usersChats)
                                                   .child(memberIdentifier)
                                                   .child(chatIdentifier)
                                                   .child("timestamp")
                                                   .setValue(Date().timeIntervalSince1970)
                        }
                    }
                }
            }
        }
    }
    
    func isChatExist(chatIdentifier: String, userIdentifier: String, completion: @escaping (Bool) -> Void) {
        databaseReference.child(Tables.usersChats)
                         .child(userIdentifier)
                         .child(chatIdentifier)
                         .observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }

    func createPairChat(chatIdentifier: String, userIdentifier1: String, userIdentifier2: String) {
        addChatMember(chatIdentifier: chatIdentifier, memberIdentifier: userIdentifier1)
        addChatMember(chatIdentifier: chatIdentifier, memberIdentifier: userIdentifier2)
        defineGroupChatStatus(chatIdentifier: chatIdentifier, isGroup: false)
    }
    
//    func createGroupChat(creatorIdentifier: String, name: String, membersIdentifiers: [String] = []) -> String? {
//        guard let chatIdentifier = databaseReference.child(Tables.chatsMessages).childByAutoId().key else {
//            return nil
//        }
//
//        addChatMember(chatIdentifier: chatIdentifier, memberIdentifier: creatorIdentifier)
//        defineGroupChatStatus(chatIdentifier: chatIdentifier, isGroup: true)
//        setGroupChatInfo(chatIdentifier: chatIdentifier, creatorIdentifier: creatorIdentifier, name: name)
//
//        membersIdentifiers.forEach { memberIdentifier in
//            addChatMember(chatIdentifier: chatIdentifier, memberIdentifier: memberIdentifier)
//        }
//
//        return chatIdentifier
//    }
    
    func addChatMember(chatIdentifier: String, memberIdentifier: String) {
        databaseReference.child(Tables.chatsMembers)
                         .child(chatIdentifier)
                         .child(memberIdentifier)
                         .setValue(true)

        databaseReference.child(Tables.usersChats)
                         .child(memberIdentifier)
                         .child(chatIdentifier)
                         .child("timestamp")
                         .setValue(Date().timeIntervalSince1970)
    }
}

// MARK: - Helper Methods

extension FirebaseDatabaseChatLogManager {
    static func getPairChatIdentifier(userIdentifier1: String, userIdentifier2: String) -> String {
        let chatIdentifier = (userIdentifier1 < userIdentifier2) ? userIdentifier1 + userIdentifier2 :
                                                                   userIdentifier2 + userIdentifier1
        return chatIdentifier
    }
}

// MARK: - Private Methods

private extension FirebaseDatabaseChatLogManager {
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
    
    func increaseUnreadMessagesCount(userIdentifier: String, chatIdentifier: String) {
        let counterReference = databaseReference.child(Tables.usersChatsUnread)
                                                .child(userIdentifier)
                                                .child(chatIdentifier)

        counterReference.runTransactionBlock { mutableDat in
            var count = 1
            
            if let value = mutableDat.value as? [String: Any],
               let unreadMessagesCount = FirebaseDatabaseCoding.fromDictionary(
                value,
                type: UsersChatsUnreadMessagesCountValue.self
               ) {
                count = unreadMessagesCount.count + 1
            }
            
            let newValue = UsersChatsUnreadMessagesCountValue(count: count, timestamp: Date().timeIntervalSince1970)
            mutableDat.value = FirebaseDatabaseCoding.toDictionary(newValue)
            
            return TransactionResult.success(withValue: mutableDat)
        }
    }
    
    func decreaseUnreadMessagesCount(userIdentifier: String, chatIdentifier: String) {
        let counterReference = databaseReference.child(Tables.usersChatsUnread)
                                                .child(userIdentifier)
                                                .child(chatIdentifier)
        
        counterReference.runTransactionBlock { mutableDat in
            if let value = mutableDat.value as? [String: Any],
               let unreadMessagesCount = FirebaseDatabaseCoding.fromDictionary(
                   value,
                   type: UsersChatsUnreadMessagesCountValue.self
               ) {
                if 0 < unreadMessagesCount.count {
                    let newValue = UsersChatsUnreadMessagesCountValue(count: unreadMessagesCount.count - 1,
                                                                      timestamp: Date().timeIntervalSince1970)
                    mutableDat.value = FirebaseDatabaseCoding.toDictionary(newValue)
                }
            }
            
            return TransactionResult.success(withValue: mutableDat)
        }
    }

    func defineGroupChatStatus(chatIdentifier: String, isGroup: Bool) {
        databaseReference.child(Tables.chatsInfo)
                         .child(chatIdentifier)
                         .setValue(isGroup)
    }
    
    func setGroupChatInfo(chatIdentifier: String, creatorIdentifier: String, name: String, imagePath: String? = nil) {
        
        let chatsInfoGroupValue = ChatsInfoGroupValue(name: name,
                                                      photoURL: imagePath,
                                                      creatorIdentifier: creatorIdentifier)
        let value = FirebaseDatabaseCoding.toDictionary(chatsInfoGroupValue)
        
        databaseReference.child(Tables.chatsInfoGroup)
                         .child(chatIdentifier)
                         .setValue(value)
    }
}
