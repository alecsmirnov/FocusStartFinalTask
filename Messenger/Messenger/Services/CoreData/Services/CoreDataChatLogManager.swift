//
//  CoreDataChatLogManager.swift
//  Messenger
//
//  Created by Admin on 17.12.2020.
//

import UIKit
import CoreData

final class CoreDataChatLogManager {
    // MARK: Properties
    
    private lazy var managedContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        return managedContext
    }()
    
    private var maxSize: Int
    private var chatLog: CoreDataChatLog?
    
    // MARK: Initialization
    
    init(maxSize: Int) {
        self.maxSize = maxSize
    }
}

// MARK: - Public Methods

extension CoreDataChatLogManager {
    func fetchData(chatIdentifier: String) {
        let chatLogFetchRequest: NSFetchRequest<CoreDataChatLog> = CoreDataChatLog.fetchRequest()
        chatLogFetchRequest.predicate = NSPredicate(format: CoreDataConstants.fetchChatLogPredicate, chatIdentifier)

        do {
            chatLog = try managedContext.fetch(chatLogFetchRequest).first
        } catch let error as NSError {
            fatalError("could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func getLatestUpdateTimestamp() -> TimeInterval {
        return chatLog?.timestamp ?? CoreDataConstants.timestampInitialValue
    }
    
    func getMessages() -> [MessageInfo] {
        var messages = [MessageInfo]()
        
        if let coreDataMessages = chatLog?.messages?.array as? [CoreDataMessage] {
            messages = coreDataMessages.map { coreDataMessageToMessage(coreDataMessage: $0) }
        }
        
        return messages
    }
    
    func appendMessage(_ message: MessageInfo) {
        if let count = chatLog?.messages?.count {
            if count == maxSize {
                chatLog?.removeFromMessages(at: 0)
            }
            
            chatLog?.addToMessages(newCoreDataMessage(with: message))
            
            saveAndUpdate()
        }
    }
    
    func removeMessage(at index: Int) {
        guard chatLog?.messages?.array.indices.contains(index) ?? false else { return }
        
        chatLog?.removeFromMessages(at: index)
        
        saveAndUpdate()
    }
    
    func resetUpdateTimestamp() {
        chatLog?.timestamp = CoreDataConstants.timestampInitialValue
        
        saveContext()
    }
    
    func clear() {
        guard let chatLog = chatLog else { return }
        
        let chatLogFetchRequest: NSFetchRequest<CoreDataChatLog> = CoreDataChatLog.fetchRequest()
        chatLogFetchRequest.predicate = NSPredicate(format: CoreDataConstants.fetchChatLogPredicate, chatLog.identifier)
        
        do {
            let objects = try managedContext.fetch(chatLogFetchRequest)
            
            objects.forEach { chatLog in
                managedContext.delete(chatLog)
            }
            
            try managedContext.save()
        } catch let error as NSError {
            fatalError("could not fetch. \(error), \(error.userInfo)")
        }
    }
}

// MARK: - Private Methods

private extension CoreDataChatLogManager {
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
        chatLog?.timestamp = Timestamp.current
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            fatalError("could not fetch. \(error), \(error.userInfo)")
        }
    }
}

// MARK: - Helper Methods

private extension CoreDataChatLogManager {
    func newCoreDataMessage(with message: MessageInfo) -> CoreDataMessage {
        let coreDataMessage = CoreDataMessage(context: managedContext)
        
        coreDataMessage.identifier = message.identifier
        coreDataMessage.senderIdentifier = message.senderIdentifier
        coreDataMessage.isRead = message.isRead
        coreDataMessage.timestamp = message.timestamp
        
        let coreDataMessageType = CoreDataMessageType(context: managedContext)
        
        switch message.type {
        case .text(let text): coreDataMessageType.text = text
        }
        
        coreDataMessage.type = coreDataMessageType
        
        return coreDataMessage
    }
    
    func coreDataMessageToMessage(coreDataMessage: CoreDataMessage) -> MessageInfo {
        let messageType: ChatsMessagesType
        
        if let text = coreDataMessage.type.text {
            messageType = ChatsMessagesType.text(text)
        } else {
            messageType = ChatsMessagesType.text("error")
        }
            
        let message = MessageInfo(identifier: coreDataMessage.identifier,
                                  senderIdentifier: coreDataMessage.senderIdentifier,
                                  type: messageType,
                                  isRead: coreDataMessage.isRead,
                                  timestamp: coreDataMessage.timestamp)
        
        return message
    }
}
