//
//  CoreDataMessage+CoreDataProperties.swift
//  Messenger
//
//  Created by Admin on 17.12.2020.
//
//

import Foundation
import CoreData

extension CoreDataMessage {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataMessage> {
        return NSFetchRequest<CoreDataMessage>(entityName: "CoreDataMessage")
    }
    
    @NSManaged public var identifier: String
    @NSManaged public var senderIdentifier: String
    @NSManaged public var isRead: Bool
    @NSManaged public var timestamp: Double
    @NSManaged public var type: CoreDataMessageType
    
    @NSManaged public var chat: CoreDataChat?
    @NSManaged public var chatLog: CoreDataChatLog?
}

extension CoreDataMessage : Identifiable {}
