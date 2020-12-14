//
//  CoreDataSession+CoreDataProperties.swift
//  Messenger
//
//  Created by Admin on 14.12.2020.
//
//

import Foundation
import CoreData

extension CoreDataSession {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataSession> {
        return NSFetchRequest<CoreDataSession>(entityName: "CoreDataSession")
    }

    @NSManaged public var user: CoreDataUser
    @NSManaged public var chats: NSSet?
    
    @NSManaged public var update_timestamp: Double
}

// MARK: Generated accessors for chats
extension CoreDataSession {
    @objc(addChatsObject:)
    @NSManaged public func addToChats(_ value: CoreDataChat)

    @objc(removeChatsObject:)
    @NSManaged public func removeFromChats(_ value: CoreDataChat)

    @objc(addChats:)
    @NSManaged public func addToChats(_ values: NSSet)

    @objc(removeChats:)
    @NSManaged public func removeFromChats(_ values: NSSet)
}

extension CoreDataSession : Identifiable {}
