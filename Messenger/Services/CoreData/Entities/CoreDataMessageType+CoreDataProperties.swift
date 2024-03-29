//
//  CoreDataMessageType+CoreDataProperties.swift
//  Messenger
//
//  Created by Admin on 15.12.2020.
//
//

import Foundation
import CoreData

extension CoreDataMessageType {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataMessageType> {
        return NSFetchRequest<CoreDataMessageType>(entityName: "CoreDataMessageType")
    }

    @NSManaged public var text: String?
    
    @NSManaged public var message: CoreDataMessage?
}

extension CoreDataMessageType : Identifiable {}
