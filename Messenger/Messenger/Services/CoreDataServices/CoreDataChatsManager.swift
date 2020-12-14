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
    
    private var session: CoreDataSession?
    
    // MARK: Initialization
    
    init() {
        fetchData()
    }
}

// MARK: - TEST

extension CoreDataChatsManager {
    func resetUpdateTimestamp() {
        session?.latestUpdateTimestamp = 0
    }
}

// MARK: - Public Methods

extension CoreDataChatsManager {
    func getLatestUpdateTimestamp() -> TimeInterval {
        return session?.latestUpdateTimestamp ?? 0
    }
    
    func setUser(_ user: UserInfo) {
        guard let coreDataUser = session?.user else { return }
        
        CoreDataChatsManager.userToCoreDataUser(user, coreDataUser: coreDataUser)
        
        updateTimestamp()
        saveContext()
    }
    
    func getUser() -> UserInfo? {
        guard let coreDataUser = session?.user else { return nil }
        
        return CoreDataChatsManager.coreDataUserToUser(coreDataUser: coreDataUser)
    }
    
    func appendChat(chat: ChatInfo) {
        let coreDataChat = chatToCoreDataChat(chat)
        
        session?.addToChats(coreDataChat)
        
        updateTimestamp()
        saveContext()
    }
    
    func updateChat(at index: Int, with chat: ChatInfo) {
        let coreDataChat = chatToCoreDataChat(chat)
        
        session?.replaceChats(at: index, with: coreDataChat)
        
        updateTimestamp()
        saveContext()
    }
    
    func removeChat(at index: Int) {
        session?.removeFromChats(at: index)
        
        updateTimestamp()
        saveContext()
    }
    
    func getChats() -> [ChatInfo] {
        guard let orderedSet = session?.chats,
              let coreDataChats = orderedSet.array as? [CoreDataChat] else { return [] }
        
        var chats = [ChatInfo]()
        
        coreDataChats.forEach { coreDataChat in
            chats.append(coreDataChatToChat(coreDataChat: coreDataChat))
        }
        
        return chats
    }
}

// MARK: - Private Methods

private extension CoreDataChatsManager {
    func fetchData() {
        let fetchRequest: NSFetchRequest<CoreDataSession> = CoreDataSession.fetchRequest()

        do {
            session = try managedContext.fetch(fetchRequest).first
            
            if session == nil {
                session = CoreDataSession(context: managedContext)
            }
        } catch let error as NSError {
            fatalError("could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func saveContext() {
        do {
            try managedContext.save()
        } catch let error as NSError {
            fatalError("could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func updateTimestamp() {
        session?.latestUpdateTimestamp = currentTimestamp
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            fatalError("could not fetch. \(error), \(error.userInfo)")
        }
    }
}

// MARK: - Helper Methods

private extension CoreDataChatsManager {
    var currentTimestamp: TimeInterval {
        return Date().timeIntervalSince1970
    }
}

private extension CoreDataChatsManager {
    static func userToCoreDataUser(_ user: UserInfo, coreDataUser: CoreDataUser) {
        coreDataUser.identifier = user.identifier
        coreDataUser.email = user.email
        coreDataUser.firstName = user.firstName
        coreDataUser.lastName = user.lastName
        coreDataUser.profileImageData = user.profileImageData
    }
    
    static func coreDataUserToUser(coreDataUser: CoreDataUser) -> UserInfo {
        return UserInfo(identifier: coreDataUser.identifier,
                        firstName: coreDataUser.firstName,
                        lastName: coreDataUser.lastName,
                        email: coreDataUser.email,
                        profileImageData: coreDataUser.profileImageData)
    }
    
    func chatToCoreDataChat(_ chat: ChatInfo) -> CoreDataChat {
        let coreDataChat = CoreDataChat(context: managedContext)
        
        coreDataChat.identifier = chat.identifier
        coreDataChat.isGroup = chat.isGroup
        
        if chat.isGroup {
            if let group = chat.group {
                let coreDataGroup = CoreDataGroup(context: managedContext)
                
                coreDataGroup.creatorIdentifier = group.creatorIdentifier
                coreDataGroup.name = group.name
                coreDataGroup.profileImageData = group.profileImageData
                
                group.moderatorsIdentifiers?.forEach { moderatorIdentifier in
                    let coreDataIdentifier = CoreDataIdentifier(context: managedContext)
                    
                    coreDataIdentifier.identifier = moderatorIdentifier
                    
                    coreDataGroup.addToModeratorsIdentifiers(coreDataIdentifier)
                }
                
                coreDataChat.group = coreDataGroup
            }
        } else {
            if let companion = chat.companion {
                let coreDataCompanion = CoreDataUser(context: managedContext)
            
                CoreDataChatsManager.userToCoreDataUser(companion, coreDataUser: coreDataCompanion)
                
                coreDataChat.companion = coreDataCompanion
            }
        }
        
        if let latestMessage = chat.latestMessage {
            let coreDataLatestMessage = CoreDataLatestMessage(context: managedContext)
            
            coreDataLatestMessage.senderIdentifier = latestMessage.senderIdentifier
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
        
        return coreDataChat
    }
    
    func coreDataChatToChat(coreDataChat: CoreDataChat) -> ChatInfo {
        var group: GroupInfo?
        var companion: UserInfo?
        
        if coreDataChat.isGroup {
            if let coreDataGroup = coreDataChat.group {
                var moderatorsIdentifiers: [String]?
                
                if let coreDataArray = coreDataGroup.moderatorsIdentifiers?.allObjects,
                   let coreDataModeratorsIdentifiers = coreDataArray as? [CoreDataIdentifier] {
                    coreDataModeratorsIdentifiers.forEach { coreDataIdentifier in
                        moderatorsIdentifiers = (moderatorsIdentifiers ?? []) + [coreDataIdentifier.identifier]
                    }
                }
                
                group = GroupInfo(creatorIdentifier: coreDataGroup.creatorIdentifier,
                                  name: coreDataGroup.name,
                                  profileImageData: coreDataGroup.profileImageData,
                                  moderatorsIdentifiers: moderatorsIdentifiers)
            }
        } else {
            if let coreDataCompanion = coreDataChat.companion {
                companion = CoreDataChatsManager.coreDataUserToUser(coreDataUser: coreDataCompanion)
            }
        }
        
        var latestMessage: LatestMessageInfo?
        
        if let coreDataLatestMessage = coreDataChat.latestMessage {
            let messageType: ChatsMessagesType
            
            if let text = coreDataLatestMessage.type?.text {
                messageType = ChatsMessagesType.text(text)
            } else {
                messageType = ChatsMessagesType.text("error")
            }
            
            latestMessage = LatestMessageInfo(senderIdentifier: coreDataLatestMessage.senderIdentifier,
                                              type: messageType,
                                              timestamp: coreDataLatestMessage.timestamp)
        }
        
        let unreadMessagesCount = Int(coreDataChat.unreadMessagesCount)
        
        let chat = ChatInfo(identifier: coreDataChat.identifier,
                            isGroup: coreDataChat.isGroup,
                            group: group,
                            companion: companion,
                            latestMessage: latestMessage,
                            unreadMessagesCount: unreadMessagesCount)
        return chat
    }
}
