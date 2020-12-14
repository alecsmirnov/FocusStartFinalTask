//
//  CoreDataLatestMessage+CoreDataProperties.swift
//  Messenger
//
//  Created by Admin on 14.12.2020.
//
//

import Foundation
import CoreData

extension CoreDataLatestMessage {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataLatestMessage> {
        return NSFetchRequest<CoreDataLatestMessage>(entityName: "CoreDataLatestMessage")
    }

    @NSManaged public var senderIdentifier: String
    @NSManaged public var timestamp: Double
    
    @NSManaged public var type: CoreDataMessageType?
    
    @NSManaged public var chat: CoreDataChat?
}

extension CoreDataLatestMessage : Identifiable {}
