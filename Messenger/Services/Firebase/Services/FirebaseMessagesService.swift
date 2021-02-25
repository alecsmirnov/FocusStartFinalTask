//
//  FirebaseMessagesService.swift
//  Messenger
//
//  Created by Admin on 19.12.2020.
//

import FirebaseDatabase

enum FirebaseMessageService {
    // MARK: Properties
    
    private enum Constants {
        static let messageIsReadKey = "is_read"
    }
    
    private static let databaseReference = Database.database().reference()
}

// MARK: - Public Editing Methods

extension FirebaseMessageService {
    static func sendMessage(_ messageType: ChatsMessagesType, chatIdentifier: String, senderIdentifier: String) {
        FirebaseChatsService.fetchChatMembersIdentifiers(chatIdentifier: chatIdentifier) { membersIdentifiers in
            guard
                let membersIdentifiers = membersIdentifiers,
                let messageIdentifier = databaseReference
                    .child(Tables.chatsMessages)
                    .child(chatIdentifier)
                    .childByAutoId().key
            else {
                return
            }
            
            let message = ChatsMessagesValue(
                senderIdentifier: senderIdentifier,
                messageType: messageType,
                timestamp: Timestamp.current,
                isRead: false)
            
            databaseReference
                .child(Tables.chatsMessages)
                .child(chatIdentifier)
                .child(messageIdentifier)
                .setValue(FirebaseDatabaseCoding.toDictionary(message))
            
            membersIdentifiers.forEach { memberIdentifier in
                databaseReference
                    .child(Tables.usersChatsMessages)
                    .child(memberIdentifier)
                    .child(chatIdentifier)
                    .child(messageIdentifier)
                    .setValue(message.timestamp)
                
                let latestMessage = UsersChatsLatestMessageValue(
                    identifier: messageIdentifier,
                    timestamp: message.timestamp)
                
                databaseReference
                    .child(Tables.usersChatsLatestMessages)
                    .child(memberIdentifier)
                    .child(chatIdentifier)
                    .setValue(FirebaseDatabaseCoding.toDictionary(latestMessage))
                    
                if message.senderIdentifier != memberIdentifier {
                    increaseUnreadMessagesCount(userIdentifier: memberIdentifier, chatIdentifier: chatIdentifier)
                    
                    databaseReference
                        .child(Tables.usersChats)
                        .child(memberIdentifier)
                        .child(chatIdentifier)
                        .observeSingleEvent(of: .value) { snapshot in
                        if !snapshot.exists() {
                            databaseReference
                                .child(Tables.usersChats)
                                .child(memberIdentifier)
                                .child(chatIdentifier)
                                .child(Timestamp.key)
                                .setValue(Timestamp.current)
                        }
                    }
                }
            }
        }
    }
    
    static func readMessage(chatIdentifier: String, userIdentifier: String, messageIdentifier: String) {
        databaseReference
            .child(Tables.chatsMessages)
            .child(chatIdentifier)
            .child(messageIdentifier)
            .child(Constants.messageIsReadKey)
            .setValue(true)

        decreaseUnreadMessagesCount(userIdentifier: userIdentifier, chatIdentifier: chatIdentifier)
    }
}

// MARK: - Public Observe Methods

extension FirebaseMessageService {
    static func observeAddedMessages(
        chatIdentifier: String,
        userIdentifier: String,
        latestUpdateTime: TimeInterval,
        limit: Int,
        completion: @escaping (MessageInfo) -> Void
    ) -> ObserverData {
        let addedMessagesReference = databaseReference
            .child(Tables.usersChatsMessages)
            .child(userIdentifier)
            .child(chatIdentifier)
        let addedMessagesHandle = addedMessagesReference
            .queryOrderedByValue()
            .queryStarting(atValue: latestUpdateTime)
            .queryLimited(toLast: UInt(limit))
            .observe(.childAdded) { snapshot in
            let messageIdentifier = snapshot.key
            
            FirebaseMessageService.fetchChatMessage(
                chatIdentifier: chatIdentifier,
                messageIdentifier: messageIdentifier) { message in
                if let message = message {
                    completion(message)
                }
            }
        }
        
        return ObserverData(reference: addedMessagesReference, handle: addedMessagesHandle)
    }
}

// MARK: - Public Fetch Methods

extension FirebaseMessageService {
    static func fetchPreviousMessages(
        chatIdentifier: String,
        userIdentifier: String,
        endingAt lastMessageTimestamp: TimeInterval,
        limit: Int,
        completion: @escaping ([MessageInfo]?) -> Void
    ) {
        databaseReference
            .child(Tables.usersChatsMessages)
            .child(userIdentifier)
            .child(chatIdentifier)
            .queryOrderedByValue()
            .queryEnding(atValue: lastMessageTimestamp)
            .queryLimited(toLast: UInt(limit + 1))
            .observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any], 1 < value.count else {
                completion(nil)
                
                return
            }

            let dispatchGroup = DispatchGroup()
            var previousMessages = [MessageInfo]()
            
            value.forEach { messageIdentifier, timestamp in
                dispatchGroup.enter()
                
                fetchChatMessageValue(
                    chatIdentifier: chatIdentifier,
                    messageIdentifier: messageIdentifier) { messageValue in
                    if let messageValue = messageValue {
                        let message = MessageInfo(
                            identifier: messageIdentifier,
                            senderIdentifier: messageValue.senderIdentifier,
                            type: messageValue.messageType,
                            isRead: messageValue.isRead,
                            timestamp: messageValue.timestamp,
                            isIncoming: messageValue.senderIdentifier != userIdentifier)
                        
                        previousMessages.append(message)
                        
                        dispatchGroup.leave()
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                var sortedPreviousMessages = previousMessages.sorted { $0.timestamp < $1.timestamp }
                sortedPreviousMessages.removeLast()
                
                completion(sortedPreviousMessages)
            }
        }
    }
    
    static func fetchChatMessage(
        chatIdentifier: String,
        messageIdentifier: String,
        completion: @escaping (MessageInfo?) -> Void
    ) {
        fetchChatMessageValue(
            chatIdentifier: chatIdentifier,
            messageIdentifier: messageIdentifier) { messageValue in
            guard let messageValue = messageValue else {
                completion(nil)
                
                return
            }
            
            completion(messageValueToMessage(messageValue, messageIdentifier: messageIdentifier))
        }
    }
    
    static func fetchChatMessageValue(
        chatIdentifier: String,
        messageIdentifier: String,
        completion: @escaping (ChatsMessagesValue?) -> Void
    ) {
        databaseReference
            .child(Tables.chatsMessages)
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

// MARK: - Private Methods

private extension FirebaseMessageService {
    static func increaseUnreadMessagesCount(userIdentifier: String, chatIdentifier: String) {
        let counterReference = databaseReference
            .child(Tables.usersChatsUnread)
            .child(userIdentifier)
            .child(chatIdentifier)

        counterReference.runTransactionBlock { mutableDat in
            var count = 1
            
            if let value = mutableDat.value as? [String: Any],
               let unreadMessagesCount = FirebaseDatabaseCoding.fromDictionary(
                value,
                type: UsersChatsUnreadMessagesCountValue.self) {
                count = unreadMessagesCount.count + 1
            }
            
            let newValue = UsersChatsUnreadMessagesCountValue(count: count, timestamp: Timestamp.current)
            mutableDat.value = FirebaseDatabaseCoding.toDictionary(newValue)
            
            return TransactionResult.success(withValue: mutableDat)
        }
    }
    
    static func decreaseUnreadMessagesCount(userIdentifier: String, chatIdentifier: String) {
        let counterReference = databaseReference
            .child(Tables.usersChatsUnread)
            .child(userIdentifier)
            .child(chatIdentifier)
        
        counterReference.runTransactionBlock { mutableDat in
            if let value = mutableDat.value as? [String: Any],
               let unreadMessagesCount = FirebaseDatabaseCoding.fromDictionary(
                value,
                type: UsersChatsUnreadMessagesCountValue.self) {
                if 0 < unreadMessagesCount.count {
                    let newValue = UsersChatsUnreadMessagesCountValue(
                        count: unreadMessagesCount.count - 1,
                        timestamp: Timestamp.current)
                    
                    mutableDat.value = FirebaseDatabaseCoding.toDictionary(newValue)
                }
            }
            
            return TransactionResult.success(withValue: mutableDat)
        }
    }
}

// MARK: - Helper Methods

extension FirebaseMessageService {
    static func messageValueToMessage(_ messageValue: ChatsMessagesValue, messageIdentifier: String) -> MessageInfo {
        let message = MessageInfo(
            identifier: messageIdentifier,
            senderIdentifier: messageValue.senderIdentifier,
            type: messageValue.messageType,
            isRead: messageValue.isRead,
            timestamp: messageValue.timestamp)
        
        return message
    }
    
    static func determineMessageDirection(_ message: MessageInfo, currentUserIdentifier: String) -> MessageInfo {
        var message = message
        message.isIncoming = message.senderIdentifier != currentUserIdentifier
        
        return message
    }
}
