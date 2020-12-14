//
//  CoreDataMessage+CoreDataProperties.swift
//  Messenger
//
//  Created by Admin on 14.12.2020.
//
//

import Foundation
import CoreData

extension CoreDataMessage {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataMessage> {
        return NSFetchRequest<CoreDataMessage>(entityName: "CoreDataMessage")
    }
}

extension CoreDataMessage : Identifiable {}
