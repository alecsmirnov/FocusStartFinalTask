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

    @NSManaged public var user: CoreDataUser?
    @NSManaged public var latestUpdateTimestamp: Double

    @NSManaged public var chats: NSOrderedSet?
}

// MARK: Generated accessors for chats

extension CoreDataSession {
    @objc(insertObject:inChatsAtIndex:)
    @NSManaged public func insertIntoChats(_ value: CoreDataChat, at idx: Int)

    @objc(removeObjectFromChatsAtIndex:)
    @NSManaged public func removeFromChats(at idx: Int)

    @objc(insertChats:atIndexes:)
    @NSManaged public func insertIntoChats(_ values: [CoreDataChat], at indexes: NSIndexSet)

    @objc(removeChatsAtIndexes:)
    @NSManaged public func removeFromChats(at indexes: NSIndexSet)

    @objc(replaceObjectInChatsAtIndex:withObject:)
    @NSManaged public func replaceChats(at idx: Int, with value: CoreDataChat)

    @objc(replaceChatsAtIndexes:withChats:)
    @NSManaged public func replaceChats(at indexes: NSIndexSet, with values: [CoreDataChat])

    @objc(addChatsObject:)
    @NSManaged public func addToChats(_ value: CoreDataChat)

    @objc(removeChatsObject:)
    @NSManaged public func removeFromChats(_ value: CoreDataChat)

    @objc(addChats:)
    @NSManaged public func addToChats(_ values: NSOrderedSet)

    @objc(removeChats:)
    @NSManaged public func removeFromChats(_ values: NSOrderedSet)
}

extension CoreDataSession : Identifiable {}
