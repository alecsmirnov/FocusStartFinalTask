//
//  CoreDataChat+CoreDataProperties.swift
//  Messenger
//
//  Created by Admin on 15.12.2020.
//
//

import Foundation
import CoreData

extension CoreDataChat {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataChat> {
        return NSFetchRequest<CoreDataChat>(entityName: "CoreDataChat")
    }

    @NSManaged public var identifier: String
    @NSManaged public var isGroup: Bool
    @NSManaged public var unreadMessagesCount: Int32
    
    @NSManaged public var companion: CoreDataUser?
    @NSManaged public var group: CoreDataGroup?
    
    @NSManaged public var latestMessage: CoreDataMessage?
}

extension CoreDataChat : Identifiable {}
