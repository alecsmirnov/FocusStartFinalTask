//
//  CoreDataChatsManager.swift
//  Messenger
//
//  Created by Admin on 14.12.2020.
//

import UIKit
import CoreData

final class CoreDataChatsManager {
    // MARK: Properties
    
    private lazy var managedContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        return managedContext
    }()
    
    private var update: CoreDataUpdate?
    private var chats = [CoreDataChat]()
    
    // MARK: Initialization
    
    init() {
        fetchData()
    }
}

// MARK: - Public Methods

extension CoreDataChatsManager {
    func getLatestUpdateTimestamp() -> TimeInterval {
        return update?.timestamp ?? CoreDataConstants.timestampInitialValue
    }
    
    func getChats() -> [ChatInfo] {
        return chats.map { coreDataChatToChat(coreDataChat: $0) }
    }
    
    func getChatIndex(by identifier: String) -> Int? {
        return chats.firstIndex { $0.identifier == identifier }
    }
    
    func getChatIdentifier(by index: Int) -> String? {
        guard chats.indices.contains(index) else { return nil }
        
        return chats[index].identifier
    }
    
    func appendChat(_ chat: ChatInfo) {
        chats.append(chatToCoreDataChat(chat))
        
        saveAndUpdate()
    }
    
    func updateChat(at identifier: String, with chat: ChatInfo) {
        if let index = getChatIndex(by: identifier) {
            chats[index] = chatToCoreDataChat(chat)
            
            saveAndUpdate()
        }
    }
    
    func removeChat(at identifier: String) {
        if let index = getChatIndex(by: identifier) {
            removeChat(at: index)
        }
    }
    
    func removeChat(at index: Int) {
        guard chats.indices.contains(index) else { return }
        
        managedContext.delete(chats[index])
        chats.remove(at: index)
        
        saveAndUpdate()
    }
    
    func updateChatCompanion(at identifier: String, companion: UserInfo) {
        if let index = getChatIndex(by: identifier) {
            CoreDataChatsManager.userToCoreDataUser(companion, coreDataUser: chats[index].companion)
        
            saveAndUpdate()
        }
    }
    
    func updateChatLatestMessage(at identifier: String, message: MessageInfo?) {
        if let index = getChatIndex(by: identifier) {
            updateChatLatestMessage(at: index, message: message)
        }
    }
    
    func updateChatLatestMessage(at index: Int, message: MessageInfo?) {
        guard chats.indices.contains(index) else { return }
        
        if let message = message {
            initLatestMessageIfEmpty(at: index)
            
            CoreDataChatsManager.messageToCoreDataMessage(message, coreDataMessage: chats[index].latestMessage)
        } else {
            chats[index].latestMessage = nil
            chats[index].unreadMessagesCount = 0
        }
        
        saveAndUpdate()
    }
    
    func updateChatUnreadMessagesCount(at identifier: String, count: Int) {
        if let index = getChatIndex(by: identifier) {
            chats[index].unreadMessagesCount = Int32(count)
            
            saveAndUpdate()
        }
    }
    
    func resetUpdateTimestamp() {
        update?.timestamp = CoreDataConstants.timestampInitialValue
        
        saveContext()
    }
    
    func clearChatLog(at index: Int) {
        let chatLogFetchRequest: NSFetchRequest<CoreDataChatLog> = CoreDataChatLog.fetchRequest()
        chatLogFetchRequest.predicate = NSPredicate(format: CoreDataConstants.fetchChatLogPredicate,
                                                    chats[index].identifier)
        
        do {
            let objects = try managedContext.fetch(chatLogFetchRequest)
            
            objects.forEach { chatLog in
                managedContext.delete(chatLog)
            }
            
            try managedContext.save()
        } catch let error as NSError {
            fatalError("could not fetch. \(error), \(error.userInfo)")
        }
        
        chats[index].chatLog = initChatLog(chatIdentifier: chats[index].identifier)
        chats[index].chatLog?.timestamp = Timestamp.current
    }
    
    func clear() {
        let updateDeleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreDataUpdate")
        let updateDeleteRequest = NSBatchDeleteRequest(fetchRequest: updateDeleteFetch)
        
        let chatDeleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreDataChat")
        let chatDeleteRequest = NSBatchDeleteRequest(fetchRequest: chatDeleteFetch)

        do {
            try managedContext.execute(updateDeleteRequest)
            try managedContext.execute(chatDeleteRequest)
            
            try managedContext.save()
        } catch let error as NSError {
            fatalError("could not fetch. \(error), \(error.userInfo)")
        }
    }
}

// MARK: - Private Methods

private extension CoreDataChatsManager {
    func fetchData() {
        let updateFetchRequest: NSFetchRequest<CoreDataUpdate> = CoreDataUpdate.fetchRequest()
        let chatsFetchRequest: NSFetchRequest<CoreDataChat> = CoreDataChat.fetchRequest()

        do {
            update = try managedContext.fetch(updateFetchRequest).first
            
            if update == nil {
                update = CoreDataUpdate(context: managedContext)
                update?.timestamp = CoreDataConstants.timestampInitialValue
            }
            
            chats = try managedContext.fetch(chatsFetchRequest)
        } catch let error as NSError {
            fatalError("could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func initLatestMessageIfEmpty(at index: Int) {
        if chats[index].latestMessage == nil {
            chats[index].latestMessage = CoreDataMessage(context: managedContext)
            chats[index].latestMessage?.type = CoreDataMessageType(context: managedContext)
        }
    }
    
    func saveAndUpdate() {
        updateTimestamp()
        saveContext()
    }
    
    func saveContext() {
        do {
            try managedContext.save()
        } catch let error as NSError {
            fatalError("could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func updateTimestamp() {
        update?.timestamp = Timestamp.current
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            fatalError("could not fetch. \(error), \(error.userInfo)")
        }
    }
}

// MARK: - Helper Methods

private extension CoreDataChatsManager {
    static func userToCoreDataUser(_ user: UserInfo, coreDataUser: CoreDataUser?) {
        coreDataUser?.identifier = user.identifier
        coreDataUser?.email = user.email
        coreDataUser?.firstName = user.firstName
        coreDataUser?.lastName = user.lastName
        coreDataUser?.profileImageURL = user.profileImageURL
    }
    
    static func coreDataUserToUser(coreDataUser: CoreDataUser) -> UserInfo {
        return UserInfo(identifier: coreDataUser.identifier,
                        firstName: coreDataUser.firstName,
                        lastName: coreDataUser.lastName,
                        email: coreDataUser.email,
                        profileImageURL: coreDataUser.profileImageURL)
    }
    
    static func messageToCoreDataMessage(_ message: MessageInfo, coreDataMessage: CoreDataMessage?) {
        coreDataMessage?.identifier = message.identifier
        coreDataMessage?.senderIdentifier = message.senderIdentifier
        coreDataMessage?.isRead = message.isRead
        coreDataMessage?.timestamp = message.timestamp
        
        switch message.type {
        case .text(let text): coreDataMessage?.type.text = text
        }
    }
    
    func chatToCoreDataChat(_ chat: ChatInfo) -> CoreDataChat {
        let coreDataChat = CoreDataChat(context: managedContext)
        
        coreDataChat.identifier = chat.identifier
    
        let coreDataCompanion = CoreDataUser(context: managedContext)
        CoreDataChatsManager.userToCoreDataUser(chat.companion, coreDataUser: coreDataCompanion)
        
        coreDataChat.companion = coreDataCompanion

        if let latestMessage = chat.latestMessage {
            let coreDataLatestMessage = CoreDataMessage(context: managedContext)
            
            coreDataLatestMessage.identifier = latestMessage.identifier
            coreDataLatestMessage.senderIdentifier = latestMessage.senderIdentifier
            coreDataLatestMessage.isRead = latestMessage.isRead
            coreDataLatestMessage.timestamp = latestMessage.timestamp
            
            let coreDataMessageType = CoreDataMessageType(context: managedContext)
            
            switch latestMessage.type {
            case .text(let text): coreDataMessageType.text = text
            }
            
            coreDataLatestMessage.type = coreDataMessageType
            coreDataChat.latestMessage = coreDataLatestMessage
        }
        
        if let unreadMessagesCount = chat.unreadMessagesCount {
            coreDataChat.unreadMessagesCount = Int32(unreadMessagesCount)
        }
        
        let coreDataChatLog = CoreDataChatLog(context: managedContext)
        coreDataChatLog.identifier = chat.identifier
        coreDataChatLog.timestamp = CoreDataConstants.timestampInitialValue
        
        coreDataChat.chatLog = initChatLog(chatIdentifier: chat.identifier)
        
        return coreDataChat
    }
    
    func coreDataChatToChat(coreDataChat: CoreDataChat) -> ChatInfo {
        let companion = CoreDataChatsManager.coreDataUserToUser(coreDataUser: coreDataChat.companion)

        var latestMessage: MessageInfo?
        
        if let coreDataLatestMessage = coreDataChat.latestMessage {
            let messageType: ChatsMessagesType
            
            if let text = coreDataLatestMessage.type.text {
                messageType = ChatsMessagesType.text(text)
            } else {
                messageType = ChatsMessagesType.text("error")
            }
            
            latestMessage = MessageInfo(identifier: coreDataLatestMessage.identifier,
                                        senderIdentifier: coreDataLatestMessage.senderIdentifier,
                                        type: messageType,
                                        isRead: coreDataLatestMessage.isRead,
                                        timestamp: coreDataLatestMessage.timestamp)
        }
        
        let unreadMessagesCount = Int(coreDataChat.unreadMessagesCount)
        
        let chat = ChatInfo(identifier: coreDataChat.identifier,
                            companion: companion,
                            latestMessage: latestMessage,
                            unreadMessagesCount: unreadMessagesCount)
        return chat
    }
    
    func initChatLog(chatIdentifier: String) -> CoreDataChatLog {
        let coreDataChatLog = CoreDataChatLog(context: managedContext)
        
        coreDataChatLog.identifier = chatIdentifier
        coreDataChatLog.timestamp = CoreDataConstants.timestampInitialValue
        
        return coreDataChatLog
    }
}
