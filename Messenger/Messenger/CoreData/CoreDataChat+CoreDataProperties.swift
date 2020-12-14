//
//  CoreDataChat+CoreDataProperties.swift
//  Messenger
//
//  Created by Admin on 14.12.2020.
//
//

import Foundation
import CoreData

extension CoreDataChat {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataChat> {
        return NSFetchRequest<CoreDataChat>(entityName: "CoreDataChat")
    }

    @NSManaged public var name: String
    @NSManaged public var session: CoreDataSession?
}

extension CoreDataChat : Identifiable {}
