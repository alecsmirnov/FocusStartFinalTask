//
//  CoreDataChatLog+CoreDataProperties.swift
//  Messenger
//
//  Created by Admin on 17.12.2020.
//
//

import Foundation
import CoreData

extension CoreDataChatLog {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataChatLog> {
        return NSFetchRequest<CoreDataChatLog>(entityName: "CoreDataChatLog")
    }

    @NSManaged public var identifier: String
    @NSManaged public var timestamp: Double
    @NSManaged public var messages: NSOrderedSet?
    
    @NSManaged public var chat: CoreDataChat?
}

// MARK: Generated accessors for messages

extension CoreDataChatLog {
    @objc(insertObject:inMessagesAtIndex:)
    @NSManaged public func insertIntoMessages(_ value: CoreDataMessage, at idx: Int)

    @objc(removeObjectFromMessagesAtIndex:)
    @NSManaged public func removeFromMessages(at idx: Int)

    @objc(insertMessages:atIndexes:)
    @NSManaged public func insertIntoMessages(_ values: [CoreDataMessage], at indexes: NSIndexSet)

    @objc(removeMessagesAtIndexes:)
    @NSManaged public func removeFromMessages(at indexes: NSIndexSet)

    @objc(replaceObjectInMessagesAtIndex:withObject:)
    @NSManaged public func replaceMessages(at idx: Int, with value: CoreDataMessage)

    @objc(replaceMessagesAtIndexes:withMessages:)
    @NSManaged public func replaceMessages(at indexes: NSIndexSet, with values: [CoreDataMessage])

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: CoreDataMessage)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: CoreDataMessage)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSOrderedSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSOrderedSet)
}

extension CoreDataChatLog : Identifiable {}
