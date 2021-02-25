//
//  CoreDataUpdate+CoreDataProperties.swift
//  Messenger
//
//  Created by Admin on 15.12.2020.
//
//

import Foundation
import CoreData

extension CoreDataUpdate {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataUpdate> {
        return NSFetchRequest<CoreDataUpdate>(entityName: "CoreDataUpdate")
    }

    @NSManaged public var timestamp: Double
}

extension CoreDataUpdate : Identifiable {}
